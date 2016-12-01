class InvoicingMilestone < ActiveRecord::Base
  belongs_to :project, class_name: 'Project', foreign_key: :project_id

  has_many :delivery_invoicing_milestones, class_name: 'DeliveryInvoicingMilestone'

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
end