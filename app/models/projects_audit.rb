class ProjectsAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :project_type_code, class_name: 'ProjectTypeCode', foreign_key: :project_type_code_id
  belongs_to :project_status, class_name: 'ProjectStatus', foreign_key: :project_status_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :sales_person, class_name: 'AdminUser', foreign_key: :sales_person_id
  belongs_to :estimator, class_name: 'AdminUser', foreign_key: :estimator_id
  belongs_to :engagement_manager, class_name: 'AdminUser', foreign_key: :engagement_manager_id
  belongs_to :delivery_manager, class_name: 'AdminUser', foreign_key: :delivery_manager_id
  belongs_to :pipeline, class_name: 'Pipeline', foreign_key: :pipeline_id
  belongs_to :project, class_name: 'Project', foreign_key: :project_id


  validates :client_id, presence: true
  validates :project_type_code_id, presence: true
  validates :project_status_id, presence: true
  validates :business_unit_id, presence: true
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :booking_value, presence: true
  validates :sales_person_id, presence: true
  validates :estimator_id, presence: true
  validates :engagement_manager_id, presence: true
  validates :delivery_manager_id, presence: true
  validates :project_id, presence: true

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']'
  end
end