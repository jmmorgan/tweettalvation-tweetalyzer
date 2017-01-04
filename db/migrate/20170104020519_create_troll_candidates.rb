class CreateTrollCandidates < ActiveRecord::Migration[5.0]
  def change
    create_table :troll_candidates do |t|
      t.datetime :profile_created_at
      t.integer :followers_count
      t.integer :friends_count
      t.boolean :has_default_profile_img
      t.boolean :has_description
      t.boolean :has_location
      t.boolean :geo_enabled
      t.integer :statuses_count
      t.integer :trump_related_sttauses_count

      t.timestamps
    end

    add_index :troll_candidates, :profile_created_at
  end
end
