class TrollCandidate < ApplicationRecord
  attr_accessor :upvoted

  def self.top(limit=10)
    query = "SELECT DISTINCT ON (x.twitter_user_id_as_string, x.votes_count) x.* 
              FROM
                (SELECT tc.*, tu.*, t.*, concat('', tu.twitter_user_id) AS twitter_user_id_as_string,
                  concat('', t.twitter_id) AS twitter_id_as_string
                  FROM troll_candidates tc
                  INNER JOIN twitter_users tu ON (tc.twitter_user_id = tu.twitter_user_id)
                  INNER JOIN tweets t ON (tc.twitter_user_id = t.twitter_user_id AND t.sentiment = 1)
                  WHERE tc.synched_with_twitter_at IS NOT NULL
                  AND tc.statuses_count > 0
                  AND tc.recently_liked_trump_tweets_count > 0
                  ORDER BY tc.votes_count DESC,
                  tc.recently_liked_trump_tweets_count DESC) as x
              ORDER BY x.votes_count DESC
              LIMIT ?"
    self.find_by_sql([query, limit])
  end

  def upvote
    TrollCandidate.increment_counter(:votes_count, self[:id])
  end
end

