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

ActiveRecord::Schema.define(version: 20160816125155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collection_posts", force: :cascade do |t|
    t.integer  "collection_id"
    t.integer  "post_id"
    t.integer  "tag_time"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["collection_id"], name: "index_collection_posts_on_collection_id", using: :btree
    t.index ["post_id"], name: "index_collection_posts_on_post_id", using: :btree
  end

  create_table "collections", force: :cascade do |t|
    t.string   "tag"
    t.string   "name"
    t.integer  "start_time"
    t.integer  "end_time"
    t.string   "next_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "insta_link"
    t.string   "insta_id"
    t.string   "media"
    t.string   "username"
    t.string   "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "media_type"
  end

end
