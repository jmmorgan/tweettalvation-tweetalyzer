class TrollCandidate < ApplicationRecord

  def self.top(limit=10)
    query = "SELECT DISTINCT ON (x.twitter_user_id_as_string) x.* 
              FROM
                (SELECT tc.*, tu.*, t.*, concat('', tu.twitter_user_id) AS twitter_user_id_as_string,
                  concat('', t.twitter_id) AS twitter_id_as_string
                  FROM troll_candidates tc
                  INNER JOIN twitter_users tu ON (tc.twitter_user_id = tu.twitter_user_id)
                  LEFT JOIN tweets t ON (tc.twitter_user_id = t.twitter_user_id AND t.sentiment = 1)
                  WHERE tc.synched_with_twitter_at IS NOT NULL and tc.trump_related_statuses_count > 0
                  ORDER BY (tc.trump_related_statuses_count * 1.0/tc.statuses_count) DESC) as x
              
              LIMIT ?"
    self.find_by_sql([query, limit])
  end
end

