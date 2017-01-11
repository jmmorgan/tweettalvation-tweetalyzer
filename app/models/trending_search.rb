class TrendingSearch < ApplicationRecord

  # All this is for Q & D demos.  WIll document and test before I use any of this in a real
  # production environment
  def self.recent(limit=10, since=1.hour.ago, fallback_to_older=true)
    searches = result = TrendingSearch.order('created_at DESC').limit(10).to_a
    result = searches.select{|ts| ts.created_at.to_i >= since.to_i}
      .uniq{|ts| ts.terms}
    # Quick and dirty fix. Fallback
    if(result.empty? && fallback_to_older)
      result = searches.uniq{|ts| ts.terms}
    end

    result
  end
end
