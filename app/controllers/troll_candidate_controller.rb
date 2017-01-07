class TrollCandidateController < ApplicationController

  # Only for DEMO purposes, mainly because I'm servicing demo pages outside of Rails
  # Do not do this in a production environment UNLESS there is some alternative
  # means of CRSF protection in place
  skip_before_action :verify_authenticity_token

  def index 
    limit = (params[:limit] || 10).to_i
    troll_candidates = TrollCandidate.top(limit)
    if(session[:upvoted])
      troll_candidates.each do |troll_candidate|
        troll_candidate.upvoted = session[:upvoted][troll_candidate[:twitter_user_id_as_string]]
      end
    end
    render json: troll_candidates, methods: [:upvoted]
  end

  def upvote
    session[:upvoted] ||= {}
    Rails.logger.info session[:upvoted]
    twitter_user_id = params[:twitter_user_id_as_string]
    if(!session[:upvoted][twitter_user_id])
      troll_candidate = TrollCandidate.find_by(twitter_user_id: params[:twitter_user_id_as_string])
      troll_candidate.upvote
      session[:upvoted][twitter_user_id] = 1
    end
    index
  end
end
