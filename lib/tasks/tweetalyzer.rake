namespace :tweetalyzer do

  task :collect_recent_tweets => [:environment] do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.where("twitter_user_id = #{twitter_user_id}").maximum(:twitter_id) || 0

    @client = twitter_rest_client
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

  task :collect_recent_replies => [:environment] do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.maximum(:twitter_id) || 0

    @client = twitter_rest_client
    twitter_user_screen_name = @client.user(twitter_user_id).screen_name

    sentiment_map = {
      Sentiment::NEGATIVE => -1,
      Sentiment::NEUTRAL => 0,
      Sentiment::POSITIVE => 1
    }

    # Just grab a sample of 1K for now
    @client.search("to:#{twitter_user_screen_name} since_id:#{last_tweet_id}").take(1000).each do |tweet|
      in_reply_to_status_id = tweet.in_reply_to_status_id.to_i
      if (in_reply_to_status_id > 0)
        sentiment = Sentimentalizer.analyze(tweet.text).sentiment
        Tweet.create(twitter_id: tweet.id, twitter_user_id: tweet.user.id, text: tweet.text,
          sentiment: sentiment_map[sentiment], in_reply_to_status_id: tweet.in_reply_to_status_id,
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

  task :backfill_tweet_dates => [:environment] do |t, args|
    
    tweets = Tweet.where(tweet_created_at: nil)
    tweets.each_slice(100) do |slice|
      ids = slice.map(&:twitter_id)

      @client = twitter_rest_client
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

    tweets = Tweet.joins('LEFT OUTER JOIN twitter_users ON tweets.twitter_user_id = twitter_users.twitter_user_id 
      WHERE twitter_users.twitter_user_id IS NULL')
    twitter_user_ids = tweets.map(&:twitter_user_id).uniq
    
    twitter_user_ids.each_slice(100) do |ids|
      @client = twitter_rest_client
      users = @client.users(ids)
      users.each do |user|
        twitter_user = TwitterUser.find_or_create_by(twitter_user_id: user.id)
        twitter_user.name = user.name
        twitter_user.screen_name = user.screen_name
        twitter_user.profile_image_url = user.profile_image_url_https
      end
    end

  end

  def twitter_rest_client  
    Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWEETALYZER_TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWEETALYZER_TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWEETALYZER_TWITTER_ACCESS_TOKEN']  
        config.access_token_secret = ENV['TWEETALYZER_TWITTER_ACCESS_SECRET']
    end
  end
end
