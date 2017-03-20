class Pipeline < ActiveRecord::Base
  acts_as_paranoid

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
  has_many :staffing_requirements, class_name: 'StaffingRequirement'

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

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :client_id, :name]
  validates_uniqueness_of :client_id, scope: [:business_unit_id, :client_id, :name]
  validates_uniqueness_of :name, scope: [:business_unit_id, :client_id, :name]

  before_create :date_check
  before_update :date_check

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
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.save
  end

  def convert_pipeline(pipeline)
    if self.engagement_manager.blank?
      errors.add(:base, I18n.t('errors.convert_pipeline_engagement_manager_missing'))
    end
    if self.delivery_manager.blank?
      errors.add(:base, I18n.t('errors.convert_pipeline_delivery_manager_missing'))
    end
    already_converted = Project.where(pipeline_id: pipeline.id).first
    if !already_converted.blank?
      errors.add(:base, I18n.t('errors.already_converted', pipeline_id: already_converted.pipeline_id, project_id: already_converted.id))
    end
    if !errors.empty?
      return false
    end
    project = Project.new
    project.name = pipeline.name
    project.start_date = pipeline.expected_start
    project.end_date = pipeline.expected_end
    project.booking_value = pipeline.expected_value
    project.comments = pipeline.comments
    project.client_id = pipeline.client_id
    project.project_type_code_id = pipeline.project_type_code_id
    project.project_status_id = ProjectStatus.where(name: I18n.t('label.new')).first.id
    project.business_unit_id = pipeline.business_unit_id
    project.estimator_id = pipeline.estimator_id
    project.engagement_manager_id = pipeline.engagement_manager_id
    project.delivery_manager_id = pipeline.delivery_manager_id
    project.pipeline_id = pipeline.id
    project.sales_person_id = pipeline.sales_person_id
    project.updated_by = pipeline.updated_by
    project.ip_address = pipeline.ip_address
    project.save
    pipeline.pipeline_status_id = PipelineStatus.where(name: I18n.t('label.delivery')).first.id
    pipeline.save
  end

  def date_check
    if self.expected_start > self.expected_end
      errors.add(:base, I18n.t('errors.date_check'))
      return false
    end
  end

  def self.pipeline_for_status(status_id, as_on, with_details, business_unit_id = -1)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_pipeline = 0
    if business_unit_id == -1
      Pipeline.where('pipeline_status_id = ? and expected_start between ? and ?', status_id, as_on.beginning_of_month, as_on.end_of_month).each do |p|
        count += 1
        total_pipeline += p.expected_value
        if with_details
          details = {}
          pipeline = p.as_json
          pipeline['expected_value'] = format_currency(p['expected_value'])
          details['pipeline'] = pipeline
          details['business_unit'] = p.business_unit.name
          details['client'] = p.client.name
          details['project_type'] = p.project_type_code.name
          details['pipeline_status'] = p.pipeline_status.name
          details['sales_person'] = p.sales_person.name
          details['estimator'] = p.estimator.name
          data << details
        end
      end
    else
      Pipeline.where('pipeline_status_id = ? and expected_start between ? and ? and business_unit_id = ?', status_id, as_on.beginning_of_month, as_on.end_of_month, business_unit_id).each do |p|
        count += 1
        total_pipeline += p.expected_value
        if with_details
          details = {}
          pipeline = p.as_json
          pipeline['expected_value'] = format_currency(p['expected_value'])
          details['pipeline'] = pipeline
          details['business_unit'] = p.business_unit.name
          details['client'] = p.client.name
          details['project_type'] = p.project_type_code.name
          details['pipeline_status'] = p.pipeline_status.name
          details['sales_person'] = p.sales_person.name
          details['estimator'] = p.estimator.name
          data << details
        end
      end
    end
    result = {}
    result['count'] = count
    result['total_pipeline'] = format_currency(total_pipeline)
    if with_details
      result['data'] = data
    end
    result
  end

  def self.pipeline_for_all_statuses(as_on, months_prior = -6, months_after = 5, business_unit_id = -1)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    result = []
    PipelineStatus.order('rank').each do |ps|
      pipeline_status_detail = {}
      pipeline_status_detail['pipeline_status'] = ps.name
      (months_prior..months_after).each do |month_offset|
        year_month = as_on + month_offset.month
        pipeline_status_detail[year_month.to_s] = Pipeline.pipeline_for_status(ps.id, year_month, false, business_unit_id)
      end
      result << pipeline_status_detail
    end
    result
  end
end