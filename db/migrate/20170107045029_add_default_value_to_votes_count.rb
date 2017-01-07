class AddDefaultValueToVotesCount < ActiveRecord::Migration[5.0]
  def change
    change_column :troll_candidates, :votes_count, :integer, default: 0
  end
end
