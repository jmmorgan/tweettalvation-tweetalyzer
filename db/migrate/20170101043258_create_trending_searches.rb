class CreateTrendingSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :trending_searches do |t|
      t.string :terms

      t.timestamps
    end

    add_index :trending_searches, :created_at
  end
end
