class TrendingSearch < ApplicationRecord

  # All this is for Q & D demos.  WIll document and test before I use any of this in a real
  # production environment
  def self.recent(limit=10, since=1.hour.ago)
    TrendingSearch.order('created_at DESC').limit(10).to_a.select{|ts| ts.created_at.to_i >= since.to_i}
      .uniq{|ts| ts.terms}
  end
end
