class Project < ActiveRecord::Base
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :project_type_code, class_name: 'ProjectTypeCode', foreign_key: :project_type_code_id
  belongs_to :project_status, class_name: 'ProjectStatus', foreign_key: :project_status_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :sales_person, class_name: 'AdminUser', foreign_key: :sales_person_id
  belongs_to :estimator, class_name: 'AdminUser', foreign_key: :estimator_id
  belongs_to :engagement_manager, class_name: 'AdminUser', foreign_key: :engagement_manager_id
  belongs_to :delivery_manager, class_name: 'AdminUser', foreign_key: :delivery_manager_id
  belongs_to :pipeline, class_name: 'Pipeline', foreign_key: :pipeline_id

  has_many :projects_audits, class_name: 'ProjectAudit'
  has_many :assigned_resources, class_name: 'AssignedResource'
  has_many :project_overheads, class_name: 'ProjectOverhead'
  has_many :delivery_milestones, class_name: 'DeliveryMilestone'
  has_many :invoicing_milestones, class_name: 'InvoicingMilestone'

  validates :name, presence: true
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

  before_create :date_check
  before_update :date_check

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :client_id]
  validates_uniqueness_of :client_id, scope: [:business_unit_id, :client_id]

  after_create :create_audit_record
  after_update :create_audit_record

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def create_audit_record
    audit_record = ProjectsAudit.new
    audit_record.name = self.name
    audit_record.description = self.description
    audit_record.start_date = self.start_date
    audit_record.end_date = self.end_date
    audit_record.booking_value = self.booking_value
    audit_record.comments = self.comments
    audit_record.created_at = self.created_at
    audit_record.updated_at = self.updated_at
    audit_record.client_id = self.client_id
    audit_record.project_type_code_id = self.project_type_code_id
    audit_record.project_status_id = self.project_status_id
    audit_record.business_unit_id = self.business_unit_id
    audit_record.estimator_id = self.estimator_id
    audit_record.engagement_manager_id = self.engagement_manager_id
    audit_record.delivery_manager_id = self.delivery_manager_id
    audit_record.pipeline_id = self.pipeline_id
    audit_record.sales_person_id = self.sales_person_id
    audit_record.project_id = self.id
    audit_record.save
  end

  def date_check
    if self.start_date > self.end_date
      raise I18n.t('errors.date_check')
    end
  end

  def invoiced_amount
    InvoiceLine.where(project_id: self.id).sum(:line_amount)
  end

  def paid_amount
    invoice_line_ids = InvoiceLine.where(project_id: self.id).pluck(:id)
    PaymentLine.where(invoice_line_id: invoice_line_ids).sum(:line_amount)
  end

  def unpaid_amount
    self.invoiced_amount - self.paid_amount
  end
end