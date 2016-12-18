class Tweet < ApplicationRecord

  def self.most_recent_from_author(twitter_user_id, limit = 10)
    Tweet.where(twitter_user_id: twitter_user_id).order('twitter_id DESC').limit(limit)
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

  def self.replies(twitter_id, sentiment = 'all', offset = 0, limit = 25)
    sentiment_int = {
      'positive' => 1,
      'negative' => -1,
      'neutral' => 0,
    }[sentiment]
    select_clause = "tweets.twitter_id, tweets.tweet_created_at, tweets.created_at, tweets.text,
                      tweets.twitter_user_id, tweets.sentiment, twitter_users.name, twitter_users.screen_name,
                      twitter_users.profile_image_url"

    joins_clause = 'LEFT JOIN twitter_users ON tweets.twitter_user_id = twitter_users.twitter_user_id'
    if (sentiment_int)
      @replies = Tweet.select(select_clause).joins(joins_clause)
        .where(in_reply_to_status_id: twitter_id, sentiment: sentiment_int)
        .order('twitter_id DESC')
        .offset(offset).limit(limit)
    else
      @replies = Tweet.select(select_clause).joins(joins_clause)
        .where(in_reply_to_status_id: twitter_id)
        .order('twitter_id DESC')
        .offset(offset).limit(limit)
    end
  end

  def self.replies_timeline(twitter_id)
    result = []
    query = "SELECT COUNT(*) AS cnt, in_reply_to_status_id, sentiment, 
            to_char(tweet_created_at, 'YYYY-Mon-DD HH:00') AS tweet_time 
            FROM tweets
            WHERE in_reply_to_status_id = ?
            GROUP BY in_reply_to_status_id, sentiment, tweet_time"
    result_set = self.find_by_sql([query, twitter_id]);
    result_set.each do |row|
      result << {
        sentiment: row.sentiment,
        count: row.cnt,
        time: row.tweet_time
      }
    end

    result
  end
end
