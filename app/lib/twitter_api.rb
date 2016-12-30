class TwitterApi

  def self.rest_client  
    Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWEETALYZER_TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWEETALYZER_TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWEETALYZER_TWITTER_ACCESS_TOKEN']  
        config.access_token_secret = ENV['TWEETALYZER_TWITTER_ACCESS_SECRET']
    end
  end

  def self.save_tweets(status_ids)
    client = rest_client
    statuses = client.statuses(status_ids)
    statuses.each do |tweet|
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

  def self.sentiment_map
    {
      Sentiment::NEGATIVE => -1,
      Sentiment::NEUTRAL => 0,
      Sentiment::POSITIVE => 1
    }
  end
end
