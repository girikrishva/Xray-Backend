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

ActiveRecord::Schema.define(version: 0) do

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

  create_table "lookup_types", force: :cascade do |t|
    t.string   "name",        :null=>false
    t.string   "description"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lookups", force: :cascade do |t|
    t.string   "name",           :null=>false
    t.string   "description"
    t.float    "rank",           :null=>false
    t.string   "comments"
    t.integer  "lookup_type_id", :null=>false, :index=>{:name=>"index_lookups_on_lookup_type_id"}, :foreign_key=>{:references=>"lookup_types", :name=>"fk_rails_ac503ee932", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extra"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.float    "rank"
    t.string   "comments"
    t.boolean  "super_admin"
    t.string   "ancestry",    :index=>{:name=>"index_roles_on_ancestry"}
    t.string   "parent_name"
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
    t.integer  "role_id",                :null=>false, :index=>{:name=>"fki_admin_users_to_roles_fk"}, :foreign_key=>{:references=>"roles", :name=>"admin_users_to_roles_fk", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "business_unit_id",       :null=>false, :index=>{:name=>"index_admin_users_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "department_id",          :null=>false, :index=>{:name=>"index_admin_users_on_department_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_department_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "designation_id",         :null=>false, :index=>{:name=>"index_admin_users_on_designation_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_designation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "active"
    t.string   "name",                   :null=>false
    t.date     "date_of_joining",        :null=>false
    t.date     "date_of_leaving"
  end

  create_table "admin_users_audits", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.integer  "admin_user_id",          :null=>false, :index=>{:name=>"index_admin_users_audit_on_admin_user_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_admin_users_audit_admin_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "business_unit_id",       :null=>false, :index=>{:name=>"index_admin_users_audits_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_audits_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "department_id",          :null=>false, :index=>{:name=>"index_admin_users_audits_on_department_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_audits_department_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "designation_id",         :null=>false, :index=>{:name=>"index_admin_users_audits_on_designation"}, :foreign_key=>{:references=>"lookups", :name=>"fk_admin_users_audits_designation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.boolean  "active"
    t.string   "name",                   :null=>false
    t.date     "date_of_joining",        :null=>false
    t.date     "date_of_leaving"
  end

  create_view "approval_statuses", <<-'END_VIEW_APPROVAL_STATUSES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Approval Statuses'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_APPROVAL_STATUSES

  create_table "clients", force: :cascade do |t|
    t.string   "name",             :null=>false
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "comments"
    t.integer  "business_unit_id", :null=>false, :index=>{:name=>"index_clients_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_clients_lookup_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pipelines", force: :cascade do |t|
    t.string   "name",                  :null=>false
    t.date     "expected_start",        :null=>false
    t.date     "expected_end",          :null=>false
    t.float    "expected_value",        :null=>false
    t.string   "comments"
    t.integer  "business_unit_id",      :null=>false, :index=>{:name=>"index_pipelines_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "client_id",             :null=>false, :index=>{:name=>"index_pipelines_on_client_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_type_code_id",  :null=>false, :index=>{:name=>"index_pipelines_on_project_type_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_project_type_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "pipeline_status_id",    :null=>false, :index=>{:name=>"index_pipelines_on_pipeline_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_pipeline_status_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_person_id",       :null=>false, :index=>{:name=>"index_pipelines_on_sales_person_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_sales_person_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "estimator_id",          :null=>false, :index=>{:name=>"index_pipelines_on_estimator_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_estimator_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "engagement_manager_id", :index=>{:name=>"index_pipelines_on_engagement_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_engagement_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "delivery_manager_id",   :index=>{:name=>"index_pipelines_on_delivery_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_delivery_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "projects", force: :cascade do |t|
    t.string   "description"
    t.date     "start_date",            :null=>false
    t.date     "end_date",              :null=>false
    t.float    "booking_value",         :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id",             :null=>false, :index=>{:name=>"index_projects_on_client_id"}, :foreign_key=>{:references=>"clients", :name=>"fk_projects_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_type_code_id",  :null=>false, :index=>{:name=>"index_projects_on_project_type_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_project_type_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_status_id",     :null=>false, :index=>{:name=>"index_projects_on_project_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_project_status_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "business_unit_id",      :null=>false, :index=>{:name=>"index_projects_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "estimator_id",          :null=>false, :index=>{:name=>"index_projects_on_estimator_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_estimator_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "engagement_manager_id", :null=>false, :index=>{:name=>"index_projects_on_engagement_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_engagement_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "delivery_manager_id",   :null=>false, :index=>{:name=>"index_projects_on_delivery_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_delivery_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "pipeline_id",           :null=>false, :index=>{:name=>"index_projects_on_pipeline_id"}, :foreign_key=>{:references=>"pipelines", :name=>"fk_projects_pipeline_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "sales_person_id",       :null=>false, :index=>{:name=>"index_projects_on_sales_person_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_admin_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "name",                  :null=>false
  end

  create_table "resources", force: :cascade do |t|
    t.boolean  "primary_skill"
    t.date     "as_on",         :null=>false
    t.float    "bill_rate",     :null=>false
    t.float    "cost_rate",     :null=>false
    t.string   "comments"
    t.integer  "admin_user_id", :null=>false, :index=>{:name=>"index_resources_on_admin_user_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_resources_admin_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "skill_id",      :null=>false, :index=>{:name=>"index_resources_on_lookup_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_resources_skill_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffing_requirements", force: :cascade do |t|
    t.date     "start_date",      :null=>false
    t.date     "end_date",        :null=>false
    t.integer  "number_required", :null=>false
    t.float    "hours_per_day",   :null=>false
    t.boolean  "fulfilled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pipeline_id",     :null=>false, :index=>{:name=>"index_staffing_requirements_on_pipeline_id"}, :foreign_key=>{:references=>"pipelines", :name=>"fk_staffing_requirements_pipeline_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "skill_id",        :null=>false, :index=>{:name=>"index_staffing_requirements_on_skill_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_staffing_requirements_skill_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "designation_id",  :null=>false, :index=>{:name=>"index_staffing_requirements_on_designation_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_staffing_requirements_designation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "comments"
  end

  create_table "assigned_resources", force: :cascade do |t|
    t.date     "as_on",                   :null=>false
    t.date     "start_date",              :null=>false
    t.date     "end_date",                :null=>false
    t.float    "hours_per_day"
    t.boolean  "delivery_due_alert"
    t.boolean  "invoicing_due_alert"
    t.boolean  "payment_due_alert"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",              :null=>false, :index=>{:name=>"index_assigned_resources_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_assigned_resources_project_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "skill_id",                :null=>false, :index=>{:name=>"index_assigned_resources_on_skill_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_assigned_resources_skill_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "designation_id",          :null=>false, :index=>{:name=>"index_assigned_resources_on_designation_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_assigned_resources_designation_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "resource_id",             :null=>false, :index=>{:name=>"index_assigned_resources_on_resource_id"}, :foreign_key=>{:references=>"resources", :name=>"fk_assigned_resources_resource_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "staffing_requirement_id", :null=>false, :index=>{:name=>"index_assigned_resources_on_staffing_requirement_id"}, :foreign_key=>{:references=>"staffing_requirements", :name=>"fk_assigned_resources_staffing_requirement_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.float    "bill_rate",               :null=>false
    t.float    "cost_rate",               :null=>false
  end

  create_view "business_units", <<-'END_VIEW_BUSINESS_UNITS', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Business Units'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_BUSINESS_UNITS

  create_view "cost_adder_types", <<-'END_VIEW_COST_ADDER_TYPES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Cost Adder Types'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_COST_ADDER_TYPES

  create_table "delivery_milestones", force: :cascade do |t|
    t.string   "name",               :null=>false
    t.string   "description"
    t.date     "due_date",           :null=>false
    t.date     "last_reminder_date"
    t.date     "completion_date"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",         :null=>false, :index=>{:name=>"index_delivery_milestones_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_delivery_milestones_project_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "invoicing_milestones", force: :cascade do |t|
    t.string   "name",               :null=>false
    t.string   "description"
    t.date     "due_date",           :null=>false
    t.date     "last_reminder_date"
    t.date     "completion_date"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",         :null=>false, :index=>{:name=>"index_invoicing_milestones_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_invoicing_milestones_project_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.float    "amount",             :null=>false
  end

  create_table "delivery_invoicing_milestones", force: :cascade do |t|
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delivery_milestone_id",  :null=>false, :index=>{:name=>"index_delivery_invoicing_milestones_on_delivery_milestone_id"}, :foreign_key=>{:references=>"delivery_milestones", :name=>"fk_delivery_invoicing_milestones_delivery_milestone_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoicing_milestone_id", :null=>false, :index=>{:name=>"index_delivery_invoicing_milestones_on_invoicing_milestone_id"}, :foreign_key=>{:references=>"invoicing_milestones", :name=>"fk_delivery_invoicing_milestones_invoicing_milestone_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_view "departments", <<-'END_VIEW_DEPARTMENTS', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Departments'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_DEPARTMENTS

  create_view "designations", <<-'END_VIEW_DESIGNATIONS', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Designations'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_DESIGNATIONS

  create_table "holiday_calendars", force: :cascade do |t|
    t.string   "name"
    t.date     "as_on"
    t.string   "description"
    t.string   "comments"
    t.integer  "business_unit_id", :null=>false, :index=>{:name=>"fk__holiday_calendars_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_holiday_calendars_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "holiday_calendars", ["business_unit_id"], :name=>"index_holiday_calendars_on_business_unit_id"

  create_view "invoice_adder_types", <<-'END_VIEW_INVOICE_ADDER_TYPES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Invoice Adder Types'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_INVOICE_ADDER_TYPES

  create_table "invoice_headers", force: :cascade do |t|
    t.string   "narrative",         :null=>false
    t.date     "invoice_date",      :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id",         :null=>false, :index=>{:name=>"index_invoice_headers_on_client_id"}, :foreign_key=>{:references=>"clients", :name=>"fk_invoice_headers_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoice_status_id", :null=>false, :index=>{:name=>"index_invoice_headers_on_invoice_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_invoice_headers_invoice_status_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoice_term_id",   :null=>false, :index=>{:name=>"index_invoice_headers_on_invoice_term_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_invoice_headers_invoice_term_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.date     "due_date",          :null=>false
    t.float    "header_amount",     :null=>false
  end

  create_table "invoice_lines", force: :cascade do |t|
    t.string   "narrative",              :null=>false
    t.float    "line_amount",            :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_header_id",      :null=>false, :index=>{:name=>"index_invoice_lines_on_invoice_header_id"}, :foreign_key=>{:references=>"invoice_headers", :name=>"fk_invoice_lines_invoice_header_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_id",             :null=>false, :index=>{:name=>"index_invoice_lines_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_invoice_lines_project_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoicing_milestone_id", :index=>{:name=>"index_invoice_lines_on_invoicing_milestone_id"}, :foreign_key=>{:references=>"invoicing_milestones", :name=>"fk_invoice_lines_invoicing_milestone_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoice_adder_type_id",  :index=>{:name=>"index_invoice_lines_on_invoice_adder_type_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_invoice_lines_invoice_adder_type_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_view "invoice_statuses", <<-'END_VIEW_INVOICE_STATUSES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Invoice Statuses'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_INVOICE_STATUSES

  create_view "invoice_terms", <<-'END_VIEW_INVOICE_TERMS', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Invoice Terms'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_INVOICE_TERMS

  create_table "overheads", force: :cascade do |t|
    t.date     "amount_date",        :null=>false
    t.float    "amount",             :null=>false
    t.string   "comments"
    t.integer  "business_unit_id",   :null=>false, :index=>{:name=>"index_overheads_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_overheads_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "department_id",      :null=>false, :index=>{:name=>"index_overheads_on_department_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_overheads_department_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "cost_adder_type_id", :null=>false, :index=>{:name=>"index_overheads_on_cost_adder_type_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_overheads_cost_adder_type_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_headers", force: :cascade do |t|
    t.string   "narrative",         :null=>false
    t.date     "payment_date",      :null=>false
    t.float    "header_amount",     :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id",         :null=>false, :index=>{:name=>"index_payment_headers_on_client_id"}, :foreign_key=>{:references=>"clients", :name=>"fk_payment_headers_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "payment_status_id", :null=>false, :index=>{:name=>"index_payment_headers_on_payment_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_payment_headers_payment_status_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "payment_lines", force: :cascade do |t|
    t.string   "narrative",         :null=>false
    t.float    "line_amount",       :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_header_id", :null=>false, :index=>{:name=>"index_payment_lines_on_payment_header_id"}, :foreign_key=>{:references=>"payment_headers", :name=>"fk_payment_lines_payment_header_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoice_line_id",   :null=>false, :index=>{:name=>"index_payment_lines_on_invoice_line_id"}, :foreign_key=>{:references=>"invoice_lines", :name=>"fk_payment_lines_invoice_line_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "invoice_header_id", :null=>false, :index=>{:name=>"index_payment_lines_on_invoice_header_id"}, :foreign_key=>{:references=>"invoice_headers", :name=>"fk_payment_lines_invoice_header_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_view "payment_statuses", <<-'END_VIEW_PAYMENT_STATUSES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Payment Statuses'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_PAYMENT_STATUSES

  create_view "pipeline_statuses", <<-'END_VIEW_PIPELINE_STATUSES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Pipeline Statuses'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_PIPELINE_STATUSES

  create_table "pipelines_audits", force: :cascade do |t|
    t.string   "name",                  :null=>false
    t.date     "expected_start",        :null=>false
    t.date     "expected_end",          :null=>false
    t.float    "expected_value",        :null=>false
    t.string   "comments"
    t.integer  "business_unit_id",      :null=>false, :index=>{:name=>"index_pipelines_audits_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_audits_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "pipeline_status_id",    :null=>false, :index=>{:name=>"index_pipelines_audits_on_pipeline_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_audits_pipeline_status_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_type_code_id",  :null=>false, :index=>{:name=>"index_pipelines_audits_on_project_type_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_pipelines_audits_project_type_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "client_id",             :null=>false, :index=>{:name=>"index_pipelines_audits_on_client_id"}, :foreign_key=>{:references=>"clients", :name=>"fk_pipelines_audits_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "pipeline_id",           :null=>false, :index=>{:name=>"index_pipelines_audits_on_pipeline_id"}, :foreign_key=>{:references=>"pipelines", :name=>"fk_pipelines_audits_pipeline_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_person_id",       :null=>false, :index=>{:name=>"index_pipelines_audits_on_sales_person_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_audits_sales_person_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "estimator_id",          :null=>false, :index=>{:name=>"index_pipelines_audits_on_estimator_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_audits_estimator_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "engagement_manager_id", :index=>{:name=>"index_pipelines_audits_on_engagement_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_audits_engagement_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "delivery_manager_id",   :index=>{:name=>"index_pipelines_audits_on_delivery_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_pipelines_audits_delivery_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "project_overheads", force: :cascade do |t|
    t.date     "amount_date",        :null=>false
    t.float    "amount",             :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_adder_type_id", :null=>false, :index=>{:name=>"index_project_overheads_on_cost_adder_type_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_project_overheads_cost_adder_type_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_id",         :null=>false, :index=>{:name=>"index_project_overheads_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_project_overheads_project_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_view "project_statuses", <<-'END_VIEW_PROJECT_STATUSES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.created_at,
    lookups.updated_at,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Project Statuses'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_PROJECT_STATUSES

  create_view "project_type_codes", <<-'END_VIEW_PROJECT_TYPE_CODES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Project Types'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_PROJECT_TYPE_CODES

  create_table "project_types", force: :cascade do |t|
    t.boolean  "billed"
    t.string   "comments"
    t.integer  "business_unit_id",     :null=>false, :index=>{:name=>"fk__project_types_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_project_types_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_type_code_id", :null=>false, :index=>{:name=>"fk__project_types_project_type_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_project_types_project_type_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "project_types", ["business_unit_id"], :name=>"index_project_types_on_business_unit_id"
  add_index "project_types", ["project_type_code_id"], :name=>"index_project_types_on_project_type_id"

  create_table "projects_audits", force: :cascade do |t|
    t.string   "description"
    t.date     "start_date",            :null=>false
    t.date     "end_date",              :null=>false
    t.float    "booking_value",         :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id",             :null=>false, :index=>{:name=>"index_projects_audits_on_client_id"}, :foreign_key=>{:references=>"clients", :name=>"fk_projects_audits_client_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_type_code_id",  :null=>false, :index=>{:name=>"index_projects_audits_on_project_type_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_audits_project_type_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_status_id",     :null=>false, :index=>{:name=>"index_projects_audits_on_project_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_audits_project_status_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "business_unit_id",      :null=>false, :index=>{:name=>"index_projects_audits_on_business_unit_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_projects_audits_business_unit_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "estimator_id",          :null=>false, :index=>{:name=>"index_projects_audits_on_estimator_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_audits_estimator_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "engagement_manager_id", :null=>false, :index=>{:name=>"index_projects_audits_on_engagement_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_audits_engagement_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "delivery_manager_id",   :null=>false, :index=>{:name=>"index_projects_audits_on_delivery_manager_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_audits_delivery_manager_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "pipeline_id",           :null=>false, :index=>{:name=>"index_projects_audits_on_pipeline_id"}, :foreign_key=>{:references=>"pipelines", :name=>"fk_projects_audits_pipeline_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "sales_person_id",       :null=>false, :index=>{:name=>"index_projects_audits_on_sales_person_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_projects_audits_admin_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "project_id",            :null=>false, :index=>{:name=>"index_projects_audits_on_project_id"}, :foreign_key=>{:references=>"projects", :name=>"fk_projects_audits_project_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "name",                  :null=>false
  end

  create_view "skills", <<-'END_VIEW_SKILLS', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Skills'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_SKILLS

  create_table "timesheets", force: :cascade do |t|
    t.date     "timesheet_date",       :null=>false
    t.float    "hours",                :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assigned_resource_id", :null=>false, :index=>{:name=>"index_timesheets_on_assigned_resource_id"}, :foreign_key=>{:references=>"assigned_resources", :name=>"fk_timesheets_assigned_resource_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "approval_status_id",   :null=>false, :index=>{:name=>"index_timesheets_on_approval_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_timesheets_lookup_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_view "vacation_codes", <<-'END_VIEW_VACATION_CODES', :force => true
SELECT lookups.id,
    lookups.name,
    lookups.description,
    lookups.rank,
    lookups.comments,
    lookups.lookup_type_id,
    lookups.extra
   FROM lookups,
    lookup_types
  WHERE (((lookup_types.name)::text = 'Vacation Codes'::text) AND (lookups.lookup_type_id = lookup_types.id))
  ORDER BY lookups.rank
  END_VIEW_VACATION_CODES

  create_table "vacation_policies", force: :cascade do |t|
    t.string   "description"
    t.date     "as_on",            :null=>false
    t.boolean  "paid",             :null=>false
    t.float    "days_allowed",     :null=>false
    t.string   "comments"
    t.integer  "business_unit_id", :null=>false, :index=>{:name=>"index_vacation_policies_on_business_unit"}, :foreign_key=>{:references=>"lookups", :name=>"fk_rails_392ec43fe8", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "vacation_code_id", :null=>false, :index=>{:name=>"index_vacation_policies_on_vacation_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_rails_392ec43fd8", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vacations", force: :cascade do |t|
    t.string   "narrative",          :null=>false
    t.date     "request_date",       :null=>false
    t.date     "start_date",         :null=>false
    t.date     "end_date",           :null=>false
    t.float    "hours_per_day",      :null=>false
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_user_id",      :null=>false, :index=>{:name=>"index_vacations_on_admin_user_id"}, :foreign_key=>{:references=>"admin_users", :name=>"fk_vacations_admin_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "vacation_code_id",   :null=>false, :index=>{:name=>"index_vacations_on_vacation_code_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_vacations_vacation_code_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "approval_status_id", :null=>false, :index=>{:name=>"index_vacations_on_approval_status_id"}, :foreign_key=>{:references=>"lookups", :name=>"fk_vacations_approval_status_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

end
