class AddTwitterUserIdToTrollCandidate < ActiveRecord::Migration[5.0]
  def change
    add_column :troll_candidates, :twitter_user_id, :integer

    add_index :troll_candidates, :twitter_user_id
  end
end
