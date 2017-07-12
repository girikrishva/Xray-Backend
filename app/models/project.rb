class Project < ActiveRecord::Base
  acts_as_paranoid
  ransacker :project_health do
  end
  ransacker :gross_profit_status do
  end

  ransacker :contribution_status do
  end

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


  def self.overall_delivery_health(as_on, contribution='all', delivery_manager_id=-1, gross_profit='all', project_status_id=-1, delivery_health='all', project_type_code_id=-1)
    result = {}
    Project.all.each do |project|
      result[project.id] = {}
      result[project.id]['project_details'] = project.project_details
      result[project.id]['missed_delivery'] = project.missed_delivery(as_on, false)
      result[project.id]['missed_invoicing'] = project.missed_invoicing(as_on, false)
      result[project.id]['missed_payments'] = project.missed_payments(as_on, false)
      result[project.id]['contribution'] = format_currency(project.contribution(as_on))
      result[project.id]['gross_profit'] = format_currency(project.gross_profit(as_on))
      result[project.id]['delivery_health'] = project.delivery_health(as_on)
    end
    if contribution == 'positive'
      result.keys.each do |r|
        if result[r]['contribution'] < 0
          result.delete(r)
        end
      end
    elsif contribution == 'negative'
      result.keys.each do |r|
        if result[r]['contribution'] >= 0
          result.delete(r)
        end
      end
    end
    if delivery_manager_id.to_i > 0
      result.keys.each do |r|
        if result[r]['project_details']['direct_details']['delivery_manager_id'] != delivery_manager_id.to_i
          result.delete(r)
        end
      end
    end
    if gross_profit == 'positive'
      result.keys.each do |r|
        if result[r]['gross_profit'] < 0
          result.delete(r)
        end
      end
    elsif gross_profit == 'negative'
      result.keys.each do |r|
        if result[r]['gross_profit'] >= 0
          result.delete(r)
        end
      end
    end
    if project_status_id.to_i > 0
      result.keys.each do |r|
        if result[r]['project_details']['direct_details']['project_status_id'] != project_status_id.to_i
          result.delete(r)
        end
      end
    end
    if !delivery_health.nil? and delivery_health.upcase != 'ALL'
      result.keys.each do |r|
        if result[r]['delivery_health'].upcase != delivery_health.upcase
          result.delete(r)
        end
      end
    end
    if project_type_code_id.to_i > 0
      result.keys.each do |r|
        if result[r]['project_details']['direct_details']['project_type_code_id'] != project_type_code_id.to_i
          result.delete(r)
        end
      end
    end
    result
  end

  def project_details
    result = {}
    direct_details = self.as_json
    direct_details['booking_value'] = format_currency(direct_details['booking_value'])
    result['direct_details'] = direct_details
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
        invoicing_milestone = im.as_json
        invoicing_milestone['amount'] = format_currency(invoicing_milestone['amount'])
        details['invoicing_milestone'] = invoicing_milestone
        details['uninvoiced'] = format_currency(im.uninvoiced)
        data << details

      end
      count += 1
      total_uninvoiced += im.uninvoiced
    end
    result = {}
    result['count'] = count
    result['total_uninvoiced'] = format_currency(total_uninvoiced)
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
          invoice_line = il.as_json
          invoice_line['line_amount'] = format_currency(invoice_line['line_amount'])
          details['invoice_line'] = invoice_line
          details['invoice_header'] = il.invoice_header
          details['client'] = il.invoice_header.client
          details['unpaid_amount'] = format_currency(il.unpaid_amount)
          data << details
        end
        count += 1
        total_unpaid += il.unpaid_amount
      end
    end
    result = {}
    result['count'] = count
    result['total_unpaid'] = format_currency(total_unpaid)
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
    AssignedResource.where('project_id = ?', self.id).order('start_date, end_date').each do |ar|
      if with_details
        details = {}
        assigned_resource = ar.as_json
        assigned_resource['bill_rate'] = assigned_resource['bill_rate']
        assigned_resource['cost_rate'] = assigned_resource['cost_rate']
        details['assigned_resource'] = assigned_resource
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
        project_overhead = po.as_json
        project_overhead['amount'] = project_overhead['amount']
        details['project_overhead'] = project_overhead
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
    x = {}
    Project.where('? between start_date and end_date', as_on).each do |p|
      if !x.has_key?(p.id)
        x[p.id] = 0
      end
      drc = p.direct_resource_cost(as_on, with_details)
      x[p.id] += drc['total_direct_resource_cost']
    end
    total_bench_cost = AdminUser.total_bench_cost(as_on)
    if x.has_key?(self.id)
      project_direct_resource_cost = x[self.id]
      total_direct_resource_cost = x.values.sum
      total_indirect_resource_cost_share = (project_direct_resource_cost / total_direct_resource_cost) * total_bench_cost
    else
      project_direct_resource_cost = 0
      total_direct_resource_cost = 0
      total_indirect_resource_cost_share = 0
    end
    # Project.
    #
    #
    #     total_direct_resource_cost_for_project = self.direct_resource_cost(as_on, false)['total_direct_resource_cost']
    #
    #
    # total_direct_resource_cost_for_all_projects = 0
    # Project.where('project_status_id = ?', ProjectStatus.id_for_status(I18n.t('label.delivery'))).each do |p|
    #   total_direct_resource_cost_for_all_projects += currency_as_amount(p.direct_resource_cost(as_on, false)['total_direct_resource_cost'])
    # end
    # if total_direct_resource_cost_for_all_projects > 0
    #   total_indirect_resource_cost_share = 0
    #   data = []
    #   count = 0
    #   lower_date = self.start_date
    #   upper_date = [self.end_date, as_on].min
    #   working_hours = (lower_date.weekdays_until(upper_date) * Rails.configuration.max_work_hours_per_day)
    #   Resource.latest(as_on).each do |r|
    #     resource_cost_share = (total_direct_resource_cost_for_project / total_direct_resource_cost_for_all_projects) * (working_hours * r.cost_rate)
    #     if with_details
    #       details = {}
    #       resource = r.as_json
    #       resource['bill_rate'] = format_currency(resource['bill_rate'])
    #       resource['cost_rate'] = format_currency(resource['cost_rate'])
    #       details['resource'] = resource
    #       details['user'] = r.admin_user.name
    #       details['skill'] = r.skill.name
    #       details['working_hours'] = working_hours
    #       details['resource_cost_share'] = format_currency(resource_cost_share)
    #       data << details
    #     end
    #     count += 1
    #     total_indirect_resource_cost_share += resource_cost_share
    #   end
    # end
    result = {}
    # result['count'] = count
    result['project_direct_resource_cost'] = project_direct_resource_cost
    result['total_direct_resource_cost'] = total_direct_resource_cost
    result['total_bench_cost'] = total_bench_cost
    result['total_indirect_resource_cost_share'] = total_indirect_resource_cost_share
    # if with_details
    #   result['data'] = data
    # end
    result
  end

  def total_indirect_overhead_cost_share(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    x = {}
    Project.where('? between start_date and end_date', as_on).each do |p|
      if !x.has_key?(p.id)
        x[p.id] = 0
      end
      drc = p.direct_resource_cost(as_on, with_details)
      x[p.id] += drc['total_direct_resource_cost']
    end
    lower_date = [self.start_date, as_on].max
    upper_date = [self.end_date, as_on].min
    total_indirect_overhead_cost = Overhead.where('business_unit_id = ? and amount_date between ? and ?', self.delivery_manager.business_unit_id, lower_date, upper_date).sum('amount')
    if x.has_key?(self.id)
      project_direct_resource_cost = x[self.id]
      total_direct_resource_cost = x.values.sum
      total_indirect_resource_cost_share = (project_direct_resource_cost / total_direct_resource_cost) * total_indirect_overhead_cost
    else
      project_direct_resource_cost = 0
      total_direct_resource_cost = 0
      total_indirect_resource_cost_share = 0
    end

    # total_direct_resource_cost_for_project = currency_as_amount(self.direct_resource_cost(as_on, false)['total_direct_resource_cost'])
    # total_direct_resource_cost_for_all_projects = 0
    # Project.where('project_status_id = ?', ProjectStatus.id_for_status(I18n.t('label.delivery'))).each do |p|
    #   total_direct_resource_cost_for_all_projects += currency_as_amount(p.direct_resource_cost(as_on, false)['total_direct_resource_cost'])
    # end
    # if total_direct_resource_cost_for_all_projects > 0
    #   total_indirect_overhead_cost_share = 0
    #   data = []
    #   count = 0
    #   lower_date = self.start_date
    #   upper_date = [self.end_date, as_on].min
    #   Overhead.where('business_unit_id = ? and amount_date between ? and ?', self.delivery_manager.business_unit_id, lower_date, upper_date).each do |o|
    #     overhead_cost_share = (total_direct_resource_cost_for_project / total_direct_resource_cost_for_all_projects) * o.amount
    #     if with_details
    #       details = {}
    #       overhead = o.as_json
    #       overhead['amount'] = format_currency(overhead['amount'])
    #       details['overhead'] = overhead
    #       details['business_unit'] = o.business_unit.name
    #       details['department'] = o.department.name
    #       details['cost_adder_type'] = o.cost_adder_type.name
    #       details['overhead_cost_share'] = format_currency(overhead_cost_share)
    #       data << details
    #     end
    #     count += 1
    #     total_indirect_overhead_cost_share += overhead_cost_share
    #   end
    # end
    result = {}
    result['project_direct_resource_cost'] = project_direct_resource_cost
    result['total_direct_resource_cost'] = total_direct_resource_cost
    result['total_indirect_overhead_cost'] = total_indirect_overhead_cost
    result['total_indirect_overhead_cost_share'] = total_indirect_resource_cost_share
    # if with_details
    #   result['data'] = data
    # end
    result
  end

  def total_indirect_cost_share(as_on)
    result = {}
    total_indirect_resource_cost_share = total_indirect_resource_cost_share(as_on, false)
    total_indirect_overhead_cost_share = total_indirect_overhead_cost_share(as_on, false)
    result['total_indirect_cost_share'] = total_indirect_resource_cost_share['total_indirect_resource_cost_share'] + total_indirect_overhead_cost_share['total_indirect_overhead_cost_share']
    result
  end

  def self.total_indirect_cost_share(project_id, as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    total_indirect_cost_share = Project.find(project_id).total_indirect_cost_share(as_on)['total_indirect_cost_share']
    format_currency(total_indirect_cost_share)
  end

  def self.total_indirect_cost_share_for_all_projects(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    total_indirect_cost_share = 0
    Project.all.each do |p|
      total_indirect_cost_share += currency_as_amount(Project.total_indirect_cost_share(p.id, Date.today.to_s))
    end
    format_currency(total_indirect_cost_share)
  end

  def total_cost(as_on)
    result = {}
    total_direct_cost = total_direct_cost(as_on)
    total_indirect_cost_share = total_indirect_cost_share(as_on)
    result['total_cost'] = total_direct_cost['total_direct_cost'] # + total_indirect_cost_share['total_indirect_cost_share']
    result
  end

  def total_revenue(as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    total_revenue = 0
    if with_details
      InvoiceLine.where('project_id = ?', self.id).each do |il|
        if il.invoice_header.invoice_date <= as_on
          details = {}
          invoice_line = il.as_json
          invoice_line['line_amount'] = format_currency(invoice_line['line_amount'])
          details['invoice_line'] = invoice_line
          invoice_header = il.invoice_header.as_json
          invoice_header['header_amount'] = format_currency(invoice_header['header_amount'])
          details['invoice_header'] = invoice_header
          details['client'] = il.invoice_header.client.name
          details['business_unit'] = il.invoice_header.client.business_unit.name
          data << details
          total_revenue += il.line_amount
        end
      end
    else
      total_revenue = InvoiceLine.where('project_id = ?', self.id).joins(:invoice_header).where('invoice_date <= ?', as_on).sum(:line_amount)
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
    total_revenue = currency_as_amount(total_revenue(as_on, false)['total_revenue'])
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

  def self.gross_profit_for_business_unit(business_unit_id, as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    gross_profit = 0
    Project.where('business_unit_id = ?', business_unit_id).each do |p|
      gross_profit += p.gross_profit(as_on.at_end_of_month)
    end
    gross_profit
  end

  def self.gross_profit(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    gross_profit = 0
    BusinessUnit.all.each do |bu|
      gross_profit += Project.gross_profit_for_business_unit(bu.id, as_on)
    end
    gross_profit
  end

  def gross_profit_details(as_on)
    result = {}
    result['total_revenue'] = total_revenue(as_on, true)
    result['direct_resource_cost'] = direct_resource_cost(as_on, true)
    result['direct_overhead_cost'] = direct_overhead_cost(as_on, true)
    result['indirect_resource_cost_share'] = total_indirect_resource_cost_share(as_on, true)
    result['indirect_overhead_cost_share'] = total_indirect_overhead_cost_share(as_on, true)
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

  def self.delivery_health(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    delivery_health = {}
    Project.all.order(:name).each do |p|
      color_code = p.delivery_health(as_on)
      if !delivery_health.has_key?(color_code)
        ids = []
        ids << p.id
        delivery_health[color_code] = ids
      else
        ids = delivery_health[color_code]
        ids << p.id
        delivery_health[color_code] = ids
      end
    end
    delivery_health
  end
end