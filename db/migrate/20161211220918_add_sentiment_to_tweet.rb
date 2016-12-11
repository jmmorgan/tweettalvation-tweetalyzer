class AddSentimentToTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :tweets, :sentiment, :int
    add_column :tweets, :in_reply_to_status_id, :bigint

    add_index :tweets, :in_reply_to_status_id
  end
end
