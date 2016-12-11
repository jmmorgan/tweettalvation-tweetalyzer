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
          sentiment: sentiment_map[sentiment], in_reply_to_status_id: tweet.in_reply_to_status_id)
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
