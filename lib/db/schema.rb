# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090603120113) do

  create_table "kopal_preference", :force => true do |t|
    t.string   "preference_name"
    t.text     "preference_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kopal_preference", ["preference_name"], :name => "index_kopal_preference_on_preference_name", :unique => true

  create_table "user_friend", :force => true do |t|
    t.string   "kopal_identity",   :null => false
    t.string   "friendship_state", :null => false
    t.string   "friendship_key",   :null => false
    t.text     "kopal_feed",       :null => false
    t.text     "public_key",       :null => false
    t.string   "friend_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_friend", ["kopal_identity"], :name => "index_user_friend_on_kopal_identity", :unique => true

end
