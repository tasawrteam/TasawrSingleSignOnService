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

ActiveRecord::Schema.define(:version => 20101025053347) do

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sso_sites", :force => true do |t|
    t.string   "domain"
    t.string   "title"
    t.string   "logo_url"
    t.text     "theme_css"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content_map"
    t.boolean  "default",       :default => false
    t.string   "template_suit"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.datetime "birthday"
    t.string   "mobile"
    t.string   "gender"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "facebook_uid",              :limit => 8
    t.string   "facebook_sid"
    t.boolean  "facebook_connect_enabled",                 :default => true
    t.integer  "twitter_uid",               :limit => 8
    t.boolean  "twitter_connect_enabled"
    t.string   "reset_password_code"
    t.boolean  "admin"
    t.integer  "sso_site_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"

end
