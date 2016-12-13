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

ActiveRecord::Schema.define(version: 20161213000112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

end
