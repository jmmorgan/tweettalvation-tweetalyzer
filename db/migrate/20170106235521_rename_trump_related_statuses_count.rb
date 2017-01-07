class RenameTrumpRelatedStatusesCount < ActiveRecord::Migration[5.0]
  def change
    rename_column :troll_candidates, :trump_related_statuses_count, :recently_liked_trump_tweets_count
  end
end
