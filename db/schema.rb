# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161109025059) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     :index=>{:name=>"index_active_admin_comments_on_namespace"}
    t.text     "body"
    t.string   "resource_id",   :null=>false
    t.string   "resource_type", :null=>false, :index=>{:name=>"index_active_admin_comments_on_resource_type_and_resource_id", :with=>["resource_id"]}
    t.integer  "author_id"
    t.string   "author_type",   :index=>{:name=>"index_active_admin_comments_on_author_type_and_author_id", :with=>["author_id"]}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  :default=>"", :null=>false, :index=>{:name=>"index_admin_users_on_email", :unique=>true}
    t.string   "encrypted_password",     :default=>"", :null=>false
    t.string   "reset_password_token",   :index=>{:name=>"index_admin_users_on_reset_password_token", :unique=>true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default=>0, :null=>false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",             :null=>false
    t.datetime "updated_at",             :null=>false
  end

  create_table "lookup_types", force: :cascade do |t|
    t.string "name",        :null=>false
    t.string "description"
    t.string "comments"
  end

  create_table "lookups", force: :cascade do |t|
    t.string  "name",           :null=>false
    t.string  "description"
    t.float   "rank",           :null=>false
    t.string  "comments"
    t.integer "lookup_type_id", :null=>false, :index=>{:name=>"index_lookups_on_lookup_type_id"}, :foreign_key=>{:references=>"lookup_types", :name=>"fk_rails_ac503ee932", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "holiday_calendars", force: :cascade do |t|
    t.string  "name"
    t.date    "as_on"
    t.string  "description"
    t.string  "comments"
    t.integer "business_unit_id", :null=>false, :index=>{:name=>"fk__holiday_calendars_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_holiday_calendars_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
  end
  add_index "holiday_calendars", ["business_unit_id"], :name=>"index_holiday_calendars_on_business_unit_id"

  create_table "vacation_policies", force: :cascade do |t|
    t.string  "description"
    t.date    "as_on",            :null=>false
    t.boolean "paid",             :null=>false
    t.float   "days_allowed",     :null=>false
    t.string  "comments"
    t.integer "business_unit_id", :null=>false, :index=>{:name=>"index_vacation_policies_on_business_unit"}, :foreign_key=>{:references=>"lookups", :name=>"fk_rails_392ec43fe8", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "vacation_code_id", :null=>false, :index=>{:name=>"index_vacation_policies_on_vacation_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_rails_392ec43fd8", :on_update=>:no_action, :on_delete=>:no_action}
  end

end
