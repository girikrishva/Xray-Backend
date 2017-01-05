class AdminUsersAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :designation, class_name: 'Designation', foreign_key: :designation_id
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :manager, class_name: 'AdminUser', foreign_key: :manager_id

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']' rescue nil
  end
end