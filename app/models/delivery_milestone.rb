class DeliveryMilestone < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :project, class_name: 'Project', foreign_key: :project_id

  has_many :delivery_invoicing_milestones, class_name: 'DeliveryInvoicingMilestone'

  validates :project_id, presence: true
  validates :name, presence: true
  validates :due_date, presence: true

  validates_uniqueness_of :project_id, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :name, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :due_date, scope: [:project_id, :name, :due_date]

  def delivery_milestone_name
    '[' + self.id.to_s + '] [' + self.name + '] due on [' + self.due_date.to_s + ']'
  end

  def project_name
    self.project.name
  end

  def self.ordered_lookup(project_id)
    DeliveryMilestone.where(project_id: project_id).order(:name)
  end

  def self.delivery_milestones(as_on, due_status, completion_status, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    if due_status.upcase == 'DUE' and completion_status.upcase == 'INCOMPLETE'
      DeliveryMilestone.where('due_date <= ? and completion_date is null', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'COMPLETE'
      DeliveryMilestone.where('due_date <= ? and completion_date is not null', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'ALL'
      DeliveryMilestone.where('due_date <= ?', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'INCOMPLETE'
      DeliveryMilestone.where('due_date > ? and completion_date is null', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'COMPLETE'
      DeliveryMilestone.where('due_date > ? and completion_date is not null', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'ALL'
      DeliveryMilestone.where('due_date > ?', as_on).order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'INCOMPLETE'
      DeliveryMilestone.where('completion_date is null').order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'COMPLETE'
      DeliveryMilestone.where('completion_date is not null').order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'ALL'
      DeliveryMilestone.all.order('due_date').each do |dm|
        details = {}
        details['id'] = dm.id
        details['name'] = dm.name
        details['due_date'] = dm.due_date.to_s
        details['last_reminder_date'] = dm.last_reminder_date
        details['completion_date'] = dm.completion_date.to_s
        details['project'] = dm.project.name
        details['client'] = dm.project.pipeline.client.name
        details['business_unit'] = dm.project.business_unit_name
        if with_details
          ids = DeliveryInvoicingMilestone.where('delivery_milestone_id = ?', dm.id).pluck('invoicing_milestone_id')
          invoicing_milestones = []
          InvoicingMilestone.where('id in (?)', ids).order('due_date').each do |im|
            invoicing_milestone = {}
            invoicing_milestone['id'] = im.id
            invoicing_milestone['name'] = im.name
            invoicing_milestone['amount'] = im.amount
            invoicing_milestone['invoiced'] = im.amount - im.uninvoiced
            invoicing_milestone['remaining'] = im.uninvoiced
            invoicing_milestone['due_date'] = im.due_date.to_s
            invoicing_milestone['last_reminder_date'] = im.last_reminder_date
            invoicing_milestone['completion_date'] = im.completion_date.to_s
            invoicing_milestone['project'] = im.project.name
            invoicing_milestone['client'] = im.project.pipeline.client.name
            invoicing_milestone['business_unit'] = im.project.business_unit_name
            invoicing_milestones << invoicing_milestone
          end
          details['invoicing_milestones'] = invoicing_milestones
        end
        data << details
      end
    end
    data
  end
end