class InvoicingMilestone < ActiveRecord::Base
  belongs_to :project, class_name: 'Project', foreign_key: :project_id

  has_many :delivery_invoicing_milestones, class_name: 'DeliveryInvoicingMilestone'
  has_many :invoice_lines, class_name: 'InvoiceLine'

  validates :project_id, presence: true
  validates :name, presence: true
  validates :due_date, presence: true
  validates :amount, presence: true

  validates_uniqueness_of :project_id, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :name, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :due_date, scope: [:project_id, :name, :due_date]

  def invoicing_milestone_name
    '[' + self.id.to_s + '] [' + self.name + '] due on [' + self.due_date.to_s + '] for the amount of [' + self.amount.to_s + ']'
  end

  def project_name
    self.project.name
  end

  def self.ordered_lookup(project_id)
    InvoicingMilestone.where(project_id: project_id).order(:name)
  end

  def self.invoicing_milestones_for_project(project_id)
    InvoicingMilestone.where(project_id: project_id).order(:due_date)
  end
end