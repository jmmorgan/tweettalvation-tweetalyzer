class WelcomeController < ApplicationController

  def index
    trump_id = 25073877
    @trump_tweets = Tweet.most_recent_from_author(trump_id)
    @trump = TwitterUser.find_by(twitter_user_id: trump_id)
    @review_stats = Tweet.review_stats(@trump_tweets)
  end
end
