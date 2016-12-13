class TwitterUser < ApplicationRecord
  validates :twitter_user_id, uniqueness: true
end
