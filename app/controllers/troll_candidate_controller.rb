class TrollCandidateController < ApplicationController

  def index 
    limit = (params[:limit] || 10).to_i
    render json: TrollCandidate.top(limit)
  end
end
