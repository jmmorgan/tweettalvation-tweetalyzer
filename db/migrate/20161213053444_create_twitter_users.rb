class CreateTwitterUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_users do |t|
      t.bigint :twitter_user_id
      t.string :screen_name
      t.string :profile_image_url

      t.timestamps
    end

    add_index :twitter_users, :id
  end
end
