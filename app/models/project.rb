class Project < ActiveRecord::Base
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
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.save!
  end

  def date_check
    if self.start_date > self.end_date
      errors.add(:base, I18n.t('errors.date_check'))
      return false
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


  def self.overall_delivery_health(as_on)
    result = {}
    Project.all.each do |project|
      result[project.id] = {}
      result[project.id]['project_details'] = project.project_details
      result[project.id]['missed_delivery'] = project.missed_delivery(as_on, false)
      result[project.id]['missed_invoicing'] = project.missed_invoicing(as_on, false)
      result[project.id]['missed_payments'] = project.missed_payments(as_on, false)
      result[project.id]['contribution'] = project.contribution(as_on)
      result[project.id]['gross_profit'] = project.gross_profit(as_on)
      result[project.id]['delivery_health'] = project.delivery_health(as_on)
    end
    result
  end

  def project_details
    result = {}
    result['direct_details'] = self
    result['lookup_details'] = self.lookup_details
    result
  end

  def lookup_details
    result = {}
    result['client'] = self.client.name
    result['project_type'] = self.project_type_code.name
    result['project_status'] = self.project_status.name
    result['business_unit'] = self.business_unit.name
    result['sales_person'] = self.sales_person.name
    result['estimator'] = self.estimator.name
    result['delivery_manager'] = self.delivery_manager.name
    result['engagement_manager'] = self.engagement_manager.name
    result['pipeline_details'] = self.pipeline.name
    result
  end

  def missed_delivery(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    DeliveryMilestone.where('project_id = ? and due_date < ? and completion_date is null', self.id, as_on).order(:due_date).each do |dm|
      if with_details
        details = {}
        details['delivery_milestone'] = dm
        data << details
      end
      count += 1
    end
    result = {}
    result['count'] = count
    if with_details
      result['data'] = data
    end
    result
  end

  def missed_invoicing(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_uninvoiced = 0
    InvoicingMilestone.where('project_id = ? and due_date < ? and completion_date is null', self.id, as_on).order(:due_date).each do |im|
      if with_details
        details = {}
        details['invoicing_milestone'] = im
        details['uninvoiced'] = im.uninvoiced
        data << details

      end
      count += 1
      total_uninvoiced += im.uninvoiced
    end
    result = {}
    result['count'] = count
    result['total_uninvoiced'] = total_uninvoiced
    if with_details
      result['data'] = data
    end
    result
  end

  def missed_payments(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_unpaid = 0
    InvoiceLine.where('project_id = ? and invoice_headers.due_date < ?', self.id, as_on).joins(:invoice_header).order('invoice_headers.id, invoice_headers.due_date').each do |il|
      if il.unpaid_amount > 0
        if with_details
          details = {}
          details['invoice_line'] = il
          details['invoice_header'] = il.invoice_header
          details['client'] = il.invoice_header.client
          details['unpaid_amount'] = il.unpaid_amount
          data << details
        end
        count += 1
        total_unpaid += il.unpaid_amount
      end
    end
    result = {}
    result['count'] = count
    result['total_unpaid'] = total_unpaid
    if with_details
      result['data'] = data
    end
    result
  end

  def direct_resource_cost(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_direct_resource_cost = 0
    AssignedResource.where('project_id = ? and ? between start_date and end_date', self.id, as_on).order('start_date, end_date').each do |ar|
      if with_details
        details = {}
        details['assigned_resource'] = ar
        details['skill'] = ar.resource.skill.name
        details['user'] = ar.resource.admin_user.name
        details['designation'] = ar.resource.admin_user.designation.name
        details['assignment_hours'] = ar.assignment_hours(as_on)
        details['direct_resource_cost'] = ar.assignment_cost(as_on)
        data << details
      end
      count += 1
      total_direct_resource_cost += ar.assignment_cost(as_on)
    end
    result = {}
    result['count'] = count
    result['total_direct_resource_cost'] = total_direct_resource_cost
    if with_details
      result['data'] = data
    end
    result
  end

  def direct_overhead_cost(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_direct_overhead_cost = 0
    ProjectOverhead.where('project_id = ? and amount_date <= ?', self.id, as_on).joins(:cost_adder_type).order('amount_date').each do |po|
      if with_details
        details = {}
        details['project_overhead'] = po
        details['cost_adder_type'] = po.cost_adder_type.name
        details['direct_overhead_cost'] = po.amount
        data << details
      end
      count += 1
      total_direct_overhead_cost += po.amount
    end
    result = {}
    result['count'] = count
    result['total_direct_overhead_cost'] = total_direct_overhead_cost
    if with_details
      result['data'] = data
    end
    result
  end

  def total_direct_cost(as_on)
    result = {}
    direct_resource_cost = direct_resource_cost(as_on, false)
    direct_overhead_cost = direct_overhead_cost(as_on, false)
    result['total_direct_cost'] = direct_resource_cost['total_direct_resource_cost'] + direct_overhead_cost['total_direct_overhead_cost']
    result
  end

  def total_indirect_resource_cost_share(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    total_direct_resource_cost_for_project = self.direct_resource_cost(as_on, false)['total_direct_resource_cost']
    total_direct_resource_cost_for_all_projects = 0
    Project.where('project_status_id = ?', ProjectStatus.id_for_status(I18n.t('label.delivery'))).each do |p|
      total_direct_resource_cost_for_all_projects += p.direct_resource_cost(as_on, false)['total_direct_resource_cost']
    end
    if total_direct_resource_cost_for_all_projects > 0
      total_indirect_resource_cost_share = 0
      data = []
      count = 0
      lower_date = self.start_date
      upper_date = [self.end_date, as_on].min
      working_hours = (lower_date.weekdays_until(upper_date) * Rails.configuration.max_work_hours_per_day)
      Resource.latest(as_on).each do |r|
        resource_cost_share = (total_direct_resource_cost_for_project / total_direct_resource_cost_for_all_projects) * (working_hours * r.cost_rate)
        if with_details
          details = {}
          details['resource'] = r
          details['user'] = r.admin_user.name
          details['skill'] = r.skill.name
          details['working_hours'] = working_hours
          details['resource_cost_share'] = resource_cost_share
          data << details
        end
        count += 1
        total_indirect_resource_cost_share += resource_cost_share
      end
    end
    result = {}
    result['count'] = count
    result['total_direct_resource_cost_for_project'] = total_direct_resource_cost_for_project
    result['total_direct_resource_cost_for_all_projects'] = total_direct_resource_cost_for_all_projects
    result['total_indirect_resource_cost_share'] = total_indirect_resource_cost_share
    if with_details
      result['data'] = data
    end
    result
  end

  def total_indirect_overhead_cost_share(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    total_direct_resource_cost_for_project = self.direct_resource_cost(as_on, false)['total_direct_resource_cost']
    total_direct_resource_cost_for_all_projects = 0
    Project.where('project_status_id = ?', ProjectStatus.id_for_status(I18n.t('label.delivery'))).each do |p|
      total_direct_resource_cost_for_all_projects += p.direct_resource_cost(as_on, false)['total_direct_resource_cost']
    end
    if total_direct_resource_cost_for_all_projects > 0
      total_indirect_overhead_cost_share = 0
      data = []
      count = 0
      lower_date = self.start_date
      upper_date = [self.end_date, as_on].min
      Overhead.where('business_unit_id = ? and amount_date between ? and ?', self.delivery_manager.business_unit_id, lower_date, upper_date).each do |o|
        overhead_cost_share = (total_direct_resource_cost_for_project / total_direct_resource_cost_for_all_projects) * o.amount
        if with_details
          details = {}
          details['overhead'] = o
          details['business_unit'] = o.business_unit.name
          details['department'] = o.department.name
          details['cost_adder_type'] = o.cost_adder_type.name
          details['overhead_cost_share'] = overhead_cost_share
          data << details
        end
        count += 1
        total_indirect_overhead_cost_share += overhead_cost_share
      end
    end
    result = {}
    result['count'] = count
    result['total_direct_resource_cost_for_project'] = total_direct_resource_cost_for_project
    result['total_direct_resource_cost_for_all_projects'] = total_direct_resource_cost_for_all_projects
    result['total_indirect_overhead_cost_share'] = total_indirect_overhead_cost_share
    if with_details
      result['data'] = data
    end
    result
  end

  def total_indirect_cost_share(as_on)
    result = {}
    total_indirect_resource_cost_share = total_indirect_resource_cost_share(as_on, false)
    total_indirect_overhead_cost_share = total_indirect_overhead_cost_share(as_on, false)
    result['total_indirect_cost_share'] = total_indirect_resource_cost_share['total_indirect_resource_cost_share'] + total_indirect_overhead_cost_share['total_indirect_overhead_cost_share'] rescue 0
    result
  end

  def total_cost(as_on)
    result = {}
    total_direct_cost = total_direct_cost(as_on)['total_direct_cost']
    total_indirect_cost_share = total_indirect_cost_share(as_on)['total_indirect_cost_share']
    result['total_cost'] = total_direct_cost + total_indirect_cost_share
    result
  end

  def total_revenue(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    total_revenue = 0
    InvoiceLine.where('project_id = ?', self.id).each do |il|
      if il.invoice_header.invoice_date <= as_on
        if with_details
          details = {}
          details['invoice_line'] = il
          details['invoice_header'] = il.invoice_header
          details['client'] = il.invoice_header.client.name
          details['business_unit'] = il.invoice_header.client.business_unit.name
          data << details
        end
        total_revenue += il.line_amount
      end
    end
    result = {}
    result['total_revenue'] = total_revenue
    if with_details
      result['data'] = data
    end
    result
  end

  def contribution(as_on)
    result = {}
    total_revenue = total_revenue(as_on, false)['total_revenue']
    total_direct_cost = total_direct_cost(as_on)['total_direct_cost']
    result = total_revenue - total_direct_cost
    result
  end

  def contribution_details(as_on)
    result = {}
    result['total_revenue'] = total_revenue(as_on, true)
    result['direct_resource_cost'] = direct_resource_cost(as_on, true)
    result['direct_overhead_cost'] = direct_overhead_cost(as_on, true)
    result
  end

  def gross_profit(as_on)
    result = {}
    total_revenue = total_revenue(as_on, false)['total_revenue']
    total_cost = total_cost(as_on)['total_cost']
    result = total_revenue - total_cost
    result
  end

  def delivery_health(as_on)
    contribution_amount = contribution(as_on)
    gross_profit_amount = gross_profit(as_on)
    missed_delivery_count = missed_delivery(as_on, false)['count']
    missed_invoicing_count = missed_invoicing(as_on, false)['count']
    missed_payments_count = missed_payments(as_on, false)['count']
    result = {}
    if contribution_amount < 0
      result = I18n.t('label.red')
    elsif contribution_amount >= 0 and gross_profit_amount >= 0 and (missed_delivery_count > 0 or missed_invoicing_count > 0 or missed_payments_count > 0)
      result = I18n.t('label.yellow')
    elsif contribution_amount >= 0 and gross_profit_amount < 0 and (missed_delivery_count > 0 or missed_invoicing_count > 0 or missed_payments_count > 0)
      result = I18n.t('label.orange')
    else
      result = I18n.t('label.green')
    end
    result
  end
end