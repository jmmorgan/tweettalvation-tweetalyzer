class AddTweetCreatedAtToTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :tweets, :tweet_created_at, :datetime
  end
end
