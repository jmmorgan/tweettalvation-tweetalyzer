class WelcomeController < ApplicationController
  include WelcomeHelper

  def index
    trump_id = 25073877
    @trump_tweets = Tweet.most_recent_from_author(trump_id, 25)
    @trump = TwitterUser.find_by(twitter_user_id: trump_id)
    @review_stats = Tweet.review_stats(@trump_tweets)
  end

  # TODO: Port some of this logic to concerns, interactors, etc. (thin controller)
  def expand_reviews
    @twitter_id = params[:twitter_id]
    @sentiment = params[:sentiment]
    @total_count = params[:count].to_i
    @page = (params[:page] || 1).to_i
    @limit = 25 # hard code for now
    @final_page = (@total_count - 1)/@limit + 1
    _build_pagination_array
    offset = (@page -1 ) * @limit
    @replies = Tweet.replies(@twitter_id, @sentiment, offset, @limit)
  end

  def expand_timeline_graph
    @twitter_id = params[:twitter_id]
  end

  def timeline_graph_data
    @twitter_id = params[:twitter_id]
    @replies_timeline_data = Tweet.replies_timeline(@twitter_id)
    @replies_timeline_data_csv = _replies_timeline_data_csv(@replies_timeline_data)
    render partial: 'timeline_graph_data'
  end

  def _build_pagination_array
    @pagination_array = []
    # get current page offset
    page_offset = ((@page - 1)/  5 ) * 5
    if (page_offset > 0)
      @pagination_array << [1, 1]
      @pagination_array << ['..', page_offset]
    end
    ((page_offset + 1)..(page_offset + 5)).each do |page|
      if (page <= @final_page)
        @pagination_array << [page, page]
      end
    end
    if (page_offset + 6 < @final_page)
      @pagination_array << ['..', page_offset + 6]
    end
    if (page_offset + 5 < @final_page)
      @pagination_array << [@final_page, @final_page]
    end

    Rails.logger.debug @pagination_array.inspect
  end
end
