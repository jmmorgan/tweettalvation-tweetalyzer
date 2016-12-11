class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.bigint :twitter_id
      t.bigint :twitter_user_id
      t.string :text

      t.timestamps
    end 

    add_index :tweets, :twitter_user_id
  end
end
