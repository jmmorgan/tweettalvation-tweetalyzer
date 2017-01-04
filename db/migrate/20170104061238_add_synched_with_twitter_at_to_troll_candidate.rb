class AddSynchedWithTwitterAtToTrollCandidate < ActiveRecord::Migration[5.0]
  def change
    add_column :troll_candidates, :synched_with_twitter_at, :datetime

    add_index :troll_candidates, :synched_with_twitter_at
  end
end
