class TweetController < ApplicationController

  def index
    ids = params[:id].to_s.split(',')
    tweets = Tweet.with_twitter_id_as_string(ids).to_a
    render json: tweets
  end

end
