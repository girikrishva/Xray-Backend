class InvoiceLine < ActiveRecord::Base
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :invoicing_milestone, class_name: 'InvoicingMilestone', foreign_key: :invoicing_milestone_id
  belongs_to :invoice_adder_type, class_name: 'InvoiceAdderType', foreign_key: :invoice_adder_type_id

  has_many :payment_lines, class_name: 'PaymentLine'

  validates :invoice_header_id, presence: true
  validates :project_id, presence: true
  validates :narrative, presence: true
  validates :line_amount, presence: true

  validates_uniqueness_of :invoice_header_id, scope: [:invoice_header_id, :project_id, :narrative]
  validates_uniqueness_of :project_id, scope: [:invoice_header_id, :project_id, :narrative]
  validates_uniqueness_of :narrative, scope: [:invoice_header_id, :project_id, :narrative]

  before_create :invoicing_milestone_invoice_adder_type_arc_check
  before_update :invoicing_milestone_invoice_adder_type_arc_check

  after_create :update_header_amount
  after_update :update_header_amount
  after_destroy :update_header_amount

  def invoice_header_name
    self.invoice_header.invoice_header_name
  end

  def invoicing_milestone_invoice_adder_type_arc_check
    if self.invoicing_milestone_id.blank? and self.invoice_adder_type_id.blank?
      raise I18n.t('errors.invoicing_milestone_invoice_adder_type_arc_error')
    end
  end

  def update_header_amount
    invoice_header = InvoiceHeader.where(id: self.invoice_header_id).first
    invoice_header.amount = InvoiceLine.where(invoice_header_id: invoice_header.id).sum(:line_amount)
    invoice_header.save
  end

  def name
    line_id = !self.invoicing_milestone.blank? ? 'Invoicing Milestone Id: [' + self.invoicing_milestone.id.to_s + ']': 'Invoice Adder Type Id: [' + self.invoice_adder_type.id.to_s + ']'
    line_detail = !self.invoicing_milestone.blank? ? 'Invoicing Milestone: [' + self.invoicing_milestone.name + ']': 'Invoice Adder Type: [' + self.invoice_adder_type.name + ']'
    line_amount = !self.invoicing_milestone.blank? ? 'Invoicing Milestone Amount: [' + self.invoicing_milestone.amount.to_s + ']': 'Invoice Adder Type Amount: [' + self.line_amount.to_s + ']'
    line_id + ', '  + line_detail + ', ' + line_amount
  end

  def unpaid_amount
    self.line_amount - PaymentLine.where(invoice_line_id: self.id).sum(:line_amount)
  end

  def self.invoice_lines_for_client(payment_header_id)
    payment_header = PaymentHeader.find(payment_header_id)
    invoice_header_ids = []
    InvoiceHeader.where(client_id: payment_header.client_id).each do |invoice_header|
      invoice_header_ids << invoice_header.id
    end
    InvoiceLine.where(invoice_header_id: invoice_header_ids)
  end
end