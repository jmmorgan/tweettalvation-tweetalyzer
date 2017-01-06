class AddTrollCandidateNominationsToTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :tweets, :troll_candidate_nominations, :integer
  
    add_index :tweets, :troll_candidate_nominations
  end
end
