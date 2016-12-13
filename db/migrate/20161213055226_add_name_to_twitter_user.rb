class AddNameToTwitterUser < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_users, :name, :string
  end
end
