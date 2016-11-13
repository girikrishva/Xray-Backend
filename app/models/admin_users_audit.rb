class AdminUsersAudit < ActiveRecord::Base
  belongs_to :AdminUser, class_name: 'AdminUser', foreign_key: :admin_user_id
end