class AdminUsersAudit < ActiveRecord::Base
  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :AdminUser, class_name: 'AdminUser', foreign_key: :admin_user_id
end