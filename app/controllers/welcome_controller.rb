class WelcomeController < ApplicationController

  def index
    @trump_tweets = Tweet.most_recent_from_author(25073877)
  end
end
