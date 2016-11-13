class AdminUsersAudit < ActiveRecord::Base
  has_ancestry

  belongs_to :AdminUser, class_name: 'AdminUser', foreign_key: :admin_user_id
end