class AdminUsersAudit < ActiveRecord::Base
  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :designation, class_name: 'Designation', foreign_key: :designation_id
  belongs_to :AdminUser, class_name: 'AdminUser', foreign_key: :admin_user_id
end