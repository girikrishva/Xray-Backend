class Designation < ActiveRecord::Base
  self.primary_key = 'id'
  
  has_many :admin_users, class_name: 'AdminUser'
end