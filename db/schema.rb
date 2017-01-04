# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170104045550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "trending_searches", force: :cascade do |t|
    t.string   "terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_trending_searches_on_created_at", using: :btree
  end

  create_table "troll_candidates", force: :cascade do |t|
    t.datetime "profile_created_at"
    t.integer  "followers_count"
    t.integer  "friends_count"
    t.boolean  "has_default_profile_img"
    t.boolean  "has_description"
    t.boolean  "has_location"
    t.boolean  "geo_enabled"
    t.integer  "statuses_count"
    t.integer  "trump_related_statuses_count"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.bigint   "twitter_user_id"
    t.index ["profile_created_at"], name: "index_troll_candidates_on_profile_created_at", using: :btree
    t.index ["twitter_user_id"], name: "index_troll_candidates_on_twitter_user_id", using: :btree
  end

  create_table "tweets", force: :cascade do |t|
    t.bigint   "twitter_id"
    t.bigint   "twitter_user_id"
    t.string   "text"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "sentiment"
    t.bigint   "in_reply_to_status_id"
    t.datetime "tweet_created_at"
    t.index ["in_reply_to_status_id"], name: "index_tweets_on_in_reply_to_status_id", using: :btree
    t.index ["twitter_user_id"], name: "index_tweets_on_twitter_user_id", using: :btree
  end

  create_table "twitter_users", force: :cascade do |t|
    t.bigint   "twitter_user_id"
    t.string   "screen_name"
    t.string   "profile_image_url"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "name"
    t.index ["id"], name: "index_twitter_users_on_id", using: :btree
  end

end
