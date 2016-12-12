class Tweet < ApplicationRecord

  def self.most_recent_from_author(twitter_user_id, limit = 10)
    Tweet.where(twitter_user_id: twitter_user_id).order('twitter_id DESC').limit(10)
  end

  def self.review_stats(tweets)
    result = {}
    twitter_ids = tweets.map(&:twitter_id)
    # prefill
    twitter_ids.each do |id|
      result[id] = {
        -1 => 0,
        0 => 0,
        1 => 0
      }
    end
    query = "SELECT COUNT(*) as cnt, in_reply_to_status_id, sentiment 
            FROM tweets
            WHERE in_reply_to_status_id IN (?)
            GROUP BY in_reply_to_status_id, sentiment"
    result_set = self.find_by_sql([query, twitter_ids]);
    result_set.each do |row|
      result[row.in_reply_to_status_id][row.sentiment] = row.cnt
    end

    result
  end
end
