class AddVotesCountToTrollCandidate < ActiveRecord::Migration[5.0]
  def change
    add_column :troll_candidates, :votes_count, :integer

    add_index :troll_candidates, :votes_count
  end
end
