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

  def twitter_rest_client  
    Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWEETALYZER_TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWEETALYZER_TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWEETALYZER_TWITTER_ACCESS_TOKEN']  
        config.access_token_secret = ENV['TWEETALYZER_TWITTER_ACCESS_SECRET']
    end
  end
end
