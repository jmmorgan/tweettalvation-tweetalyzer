class AddTrollCandidateNominationsToTweet < ActiveRecord::Migration[5.0]
  def change
    add_column :tweets, :troll_candidate_nominations, :integer
  
    add_index :troll_candidate_nominations, :tweets
  end
end
