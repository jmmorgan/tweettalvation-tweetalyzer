class Tweet < ApplicationRecord

  def self.most_recent_from_author(twitter_user_id, limit = 10)
    Tweet.where(twitter_user_id: twitter_user_id).order('twitter_id DESC').limit(10)
  end
end
