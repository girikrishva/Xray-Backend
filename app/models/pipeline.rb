class Pipeline < ActiveRecord::Base
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :pipeline_status, class_name: 'PipelineStatus', foreign_key: :pipeline_status_id
  belongs_to :project_type_code, class_name: 'ProjectTypeCode', foreign_key: :project_type_code_id
  belongs_to :sales_person, class_name: 'AdminUser', foreign_key: :sales_person_id
  belongs_to :estimator, class_name: 'AdminUser', foreign_key: :estimator_id
  belongs_to :engagement_manager, class_name: 'AdminUser', foreign_key: :engagement_manager_id
  belongs_to :delivery_manager, class_name: 'AdminUser', foreign_key: :delivery_manager_id

  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'

  validates :business_unit_id, presence: true
  validates :client_id, presence: true
  validates :pipeline_status_id, presence: true
  validates :project_type_code_id, presence: true
  validates :name, presence: true
  validates :expected_start, presence: true
  validates :expected_end, presence: true
  validates :expected_value, presence: true
  validates :sales_person_id, presence: true
  validates :estimator_id, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :client_id]
  validates_uniqueness_of :client_id, scope: [:business_unit_id, :client_id]

  after_create :create_audit_record
  after_update :create_audit_record

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def create_audit_record
    audit_record = PipelinesAudit.new
    audit_record.business_unit_id = self.business_unit.id
    audit_record.client_id = self.client.id
    audit_record.name = self.name
    audit_record.project_type_code_id = self.project_type_code_id
    audit_record.pipeline_status_id = self.pipeline_status_id
    audit_record.expected_start = self.expected_start
    audit_record.expected_end = self.expected_end
    audit_record.expected_value = self.expected_value
    audit_record.comments = self.comments
    audit_record.pipeline_id = self.id
    audit_record.sales_person_id = self.sales_person_id
    audit_record.estimator_id = self.estimator_id
    audit_record.save
  end
end