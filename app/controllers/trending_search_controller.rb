class TrendingSearchController < ApplicationController

  def recent
    limit = params[:limit] || 10
    render json: TrendingSearch.recent(limit)
  end
end
