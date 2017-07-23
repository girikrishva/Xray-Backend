class Department < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :admin_users, class_name: 'AdminUser'
  has_many :admin_users_audits, class_name: 'AdminUserAudit'

  default_scope { order(updated_at: :desc) }
end