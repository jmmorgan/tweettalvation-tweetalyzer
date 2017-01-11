namespace :tweetalyzer do

  # Past hour
  TRENDING_SEARCH_URL = "https://www.google.com/trends/fetchComponent?hl=en-US&q=Donald%20Trump&date=now%201-H&geo=US&cid=RISING_QUERIES_0_0"
  
  # Past day (try this when past hour is returning 500)
  TRENDING_SEARCH_URL_FALLBACK = "https://www.google.com/trends/fetchComponent?hl=en-US&q=Donald%20Trump&date=now%201-d&geo=US&cid=RISING_QUERIES_0_0"


  task :init_vars => [:environment] do |t, args|
    # DRY this up as we port over to TwitterAPI
    @sentiment_map = {
      Sentiment::NEGATIVE => -1,
      Sentiment::NEUTRAL => 0,
      Sentiment::POSITIVE => 1
    }
  end

  task :collect_recent_tweets => [:environment] do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.where("twitter_user_id = #{twitter_user_id}").maximum(:twitter_id) || 0

    @client = TwitterApi.rest_client
    if (!twitter_user = TwitterUser.find_by(twitter_user_id: twitter_user_id))
      user = @client.user(twitter_user_id)
      twitter_user = TwitterUser.create(twitter_user_id: twitter_user_id, name: user.name, screen_name: user.screen_name,
        profile_image_url: user.profile_image_url_https)
    end
    
    @client.search("from:#{twitter_user.screen_name} since_id:#{last_tweet_id}").take(100).each do |tweet|
      Tweet.create(twitter_id: tweet.id, twitter_user_id: tweet.user.id, text: tweet.text,
        tweet_created_at: tweet.created_at)
    end
  end

  task :collect_recent_replies => :init_vars do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.maximum(:twitter_id) || 0

    @client = TwitterApi.rest_client
    twitter_user_screen_name = @client.user(twitter_user_id).screen_name

    # Just grab a sample of 1K for now
    @client.search("to:#{twitter_user_screen_name} since_id:#{last_tweet_id}").take(1000).each do |tweet|
      in_reply_to_status_id = tweet.in_reply_to_status_id.to_i
      if (in_reply_to_status_id > 0)
        sentiment = Sentimentalizer.analyze(tweet.text).sentiment
        Tweet.create(twitter_id: tweet.id, twitter_user_id: tweet.user.id, text: tweet.text,
          sentiment: @sentiment_map[sentiment], in_reply_to_status_id: tweet.in_reply_to_status_id,
          tweet_created_at: tweet.created_at)
        user = tweet.user
        twitter_user_id = tweet.user.id
        if (!TwitterUser.find_by(twitter_user_id: twitter_user_id))
          TwitterUser.create(twitter_user_id: twitter_user_id, name: user.name, screen_name: user.screen_name,
            profile_image_url: user.profile_image_url_https)
        end
      end
    end
  end

  task :collect_recent_trending_searches => [:environment] do |t, args|
    begin
      doc = Nokogiri::HTML(open(TRENDING_SEARCH_URL))
    rescue
      doc = Nokogiri::HTML(open(TRENDING_SEARCH_URL_FALLBACK))
    end
    search_terms = doc.xpath("//*[contains(@class, 'trends-bar-chart-name')]").map(&:text).map(&:strip).uniq
    search_terms.each do |search_term|
      TrendingSearch.create(terms: search_term)
    end
  end

  task :backfill_tweet_dates => [:environment] do |t, args|
    
    tweets = Tweet.where(tweet_created_at: nil)
    tweets.each_slice(100) do |slice|
      ids = slice.map(&:twitter_id)

      @client = TwitterApi.rest_client
      statuses = @client.statuses(ids)
      statuses.each do |status|
        tweet = Tweet.find_by(twitter_id: status.id)
        if (tweet)
          tweet.tweet_created_at = status.created_at
          tweet.save
        end
      end
    end

  end

  task :backfill_twitter_users => [:environment] do |t, args|

    #tweets = Tweet.joins('LEFT JOIN twitter_users ON tweets.twitter_user_id = twitter_users.twitter_user_id 
      #WHERE twitter_users.twitter_user_id IS NULL')
    #twitter_user_ids = tweets.map(&:twitter_user_id).uniq
    twitter_user_ids = TwitterUser.where(screen_name: nil).map(&:twitter_user_id).uniq
    
    twitter_user_ids.each_slice(100) do |ids|
      @client = TwitterApi.rest_client
      users = @client.users(ids)
      users.each do |user|
        twitter_user = TwitterUser.find_or_create_by(twitter_user_id: user.id)
        twitter_user.name = user.name
        twitter_user.screen_name = user.screen_name
        twitter_user.profile_image_url = user.profile_image_url_https
        twitter_user.save
      end
    end

  end

  task :reclassify_tweets => :init_vars do |t, args|
    tweet_count = 0
    Tweet.find_in_batches do |tweets|
      tweets.each do |tweet|
        tweet_count += 1
        sentiment = @sentiment_map[Sentimentalizer.analyze(tweet.text).sentiment]
        if(sentiment != tweet.sentiment)
          puts "Reclassifying tweet #{tweet.twitter_id}"
          tweet.update(sentiment: sentiment)
        end
        if (tweet_count % 100 == 0)
          puts "Completed processing #{tweet_count} tweets"
        end
      end
    end

  end

  task :hunt_for_likely_trolls => :init_vars do |t, args|  
    
    limit = 100
    offset = 0
    query = "SELECT DISTINCT tu.twitter_user_id, tu.profile_image_url, t.sentiment,
              tc.id
              FROM twitter_users tu
              JOIN tweets t ON (tu.twitter_user_id = t.twitter_user_id)
              LEFT JOIN troll_candidates tc ON (tu.twitter_user_id = tc.twitter_user_id)
              WHERE t.sentiment = 1
              AND tc.id IS NULL
              ORDER BY tu.twitter_user_id DESC
              LIMIT ? OFFSET ?"
    more_results = true
    while(more_results)
      user_ids = []
      puts "Retrieving users from offset #{offset}..."
      results = TwitterUser.find_by_sql([query, limit, offset])
      more_results = !results.empty?
      results.each do |twitter_user|
        user_ids << twitter_user['twitter_user_id']
      end
      sleep 2 # put this here so we don't exceed API limit 
      client = TwitterApi.rest_client
      process_users_for_likely_trolls(client.users(user_ids))

      offset += limit
    end    
  end

  def process_users_for_likely_trolls(twitter_users)
    twitter_users.each do |twitter_user|
      add_or_update_candidate = false
      # Add or update candiate if one of the following conditions is true
      if (twitter_user.profile_image_url.to_s =~ /default_profile_images/ )
        add_or_update_candidate = true
      elsif (twitter_user.description.to_s.blank? || twitter_user.location.to_s.blank?)
        add_or_update_candidate = true
      elsif (twitter_user.followers_count < 20)
        add_or_update_candidate = true
      end

      if(add_or_update_candidate)
        troll_candidate = TrollCandidate.find_or_create_by(twitter_user_id: twitter_user.id)
        update_troll_candidate(troll_candidate, twitter_user)
      end
    end
  end

  def update_troll_candidate(troll_candidate, twitter_user, synch_with_twitter = false)
    troll_candidate.profile_created_at = twitter_user.created_at
    troll_candidate.followers_count = twitter_user.followers_count
    troll_candidate.friends_count = twitter_user.friends_count
    troll_candidate.statuses_count = twitter_user.statuses_count
    troll_candidate.geo_enabled = twitter_user.geo_enabled?
    troll_candidate.has_description = !twitter_user.description.to_s.blank?
    troll_candidate.has_location = !twitter_user.location.to_s.blank?
    troll_candidate.has_default_profile_img = (twitter_user.profile_image_url.to_s =~ /default_profile_images/ )

    if (synch_with_twitter)
      client = TwitterApi.rest_client
      # Get last 200 tweets
      favorites = client.favorites(user_id: twitter_user.id, count: 200)
      trump_authored_tweets_count = 0
      favorites.each do |tweet|
        if(tweet.user.screen_name == 'realDonaldTrump')
          trump_authored_tweets_count += 1
        end 
      end
      troll_candidate.recently_liked_trump_tweets_count = trump_authored_tweets_count
      troll_candidate.synched_with_twitter_at = DateTime.now.getutc
    end

    troll_candidate.save
  end

  task :sync_troll_candidates_with_twitter => :init_vars do |t, args| 
    # Select a 'random' section of max 500 users to sync
    # start with a relation that narrows things down A LOT
    limit = 50 # Small limit for now
    troll_candidates = TrollCandidate.select('random() AS rnd, troll_candidates.*')
                .where(has_default_profile_img: true, has_description: false, has_location: false)
                .where('followers_count < 10').where('statuses_count > 50')
                .order('rnd')
                .limit(limit).to_a
    troll_candidates_map = troll_candidates.inject({}) do |memo, troll_candidate|
      memo[troll_candidate.twitter_user_id] = troll_candidate
      memo
    end
    
    client = TwitterApi.rest_client
    troll_candidates_map.keys.each_slice(100) do |slice|
      client.users(slice).each do |twitter_user|
        troll_candidate = troll_candidates_map[twitter_user.id]
        update_troll_candidate(troll_candidate, twitter_user, true)
      end
    end
  end
end
