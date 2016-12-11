namespace :tweetalyzer do

  task :collect_recent_tweets => [:environment] do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.where("twitter_user_id = #{twitter_user_id}").maximum(:twitter_id) || 0

    @client = twitter_rest_client
    twitter_user_screen_name = @client.user(twitter_user_id).screen_name
    
    @client.search("from:#{twitter_user_screen_name} since_id:#{last_tweet_id}").take(100).each do |tweet|
      Tweet.create(twitter_id: tweet.id, twitter_user_id: tweet.user.id, text: tweet.text)
    end
  end

  task :collect_recent_replies => [:environment] do |t, args|
    twitter_user_id = args[:twitter_user_id] ||  25073877 #@realDonaldTrump
    twitter_user_id = twitter_user_id.to_i # Ensure int format
    last_tweet_id = Tweet.maximum(:twitter_id) || 0

    @client = twitter_rest_client
    twitter_user_screen_name = @client.user(twitter_user_id).screen_name

    reply_buckets = {}
    @client.search("to:#{twitter_user_screen_name} since_id:#{last_tweet_id}").take(10).each do |tweet|
      in_reply_to_status_id = tweet.in_reply_to_status_id.to_i
      if (in_reply_to_status_id > 0)
        sentiment = Sentimentalizer.analyze(tweet.text)
        reply_buckets[in_reply_to_status_id] ||= []
        reply_buckets[in_reply_to_status_id] << sentiment
      end
    end

    puts reply_buckets
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
