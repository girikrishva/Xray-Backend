class Designation < ActiveRecord::Base
  self.primary_key = 'id'
  
  has_many :admin_users, class_name: 'AdminUser'
  has_many :admin_users_audits, class_name: 'AdminUserAudit'
end