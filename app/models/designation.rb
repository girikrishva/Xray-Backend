class Designation < ActiveRecord::Base
  self.primary_key = 'id'
  
  has_many :admin_users, class_name: 'AdminUser'
  has_many :admin_users_audits, class_name: 'AdminUserAudit'
  has_many :staffing_requirements, class_name: 'StaffingRequirement'
end