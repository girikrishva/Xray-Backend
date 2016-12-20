class InvoiceLine < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :invoicing_milestone, class_name: 'InvoicingMilestone', foreign_key: :invoicing_milestone_id
  belongs_to :invoice_adder_type, class_name: 'InvoiceAdderType', foreign_key: :invoice_adder_type_id

  has_many :payment_lines, class_name: 'PaymentLine'
  has_many :invoice_lines_audits, class_name: 'InvoiceLinesAudit'

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

  after_create :create_audit_record
  after_update :create_audit_record

  def name
    self.invoice_line_name
  end

  def invoice_header_name
    self.invoice_header.invoice_header_name
  end

  def invoicing_milestone_invoice_adder_type_arc_check
    if self.invoicing_milestone_id.blank? and self.invoice_adder_type_id.blank?
      errors.add(:base, I18n.t('errors.invoicing_milestone_invoice_adder_type_arc_error'))
      return false
    end
  end

  def update_header_amount
    invoice_header = InvoiceHeader.where(id: self.invoice_header_id).first
    invoice_header.header_amount = InvoiceLine.where(invoice_header_id: invoice_header.id).sum(:line_amount)
    invoice_header.save
  end

  def invoice_line_name
    'Id: [' + self.id.to_s + '], Narrative: [' + self.narrative + '], Amount: [' + self.line_amount.to_s + '], Unpaid: [' + self.unpaid_amount.to_s + ']'
  end

  def unpaid_amount
    self.line_amount - PaymentLine.where(invoice_line_id: self.id).sum(:line_amount)
  end

  def create_audit_record
    audit_record = InvoiceLinesAudit.new
    audit_record.narrative = self.narrative
    audit_record.line_amount = self.line_amount
    audit_record.invoice_header_id = self.invoice_header_id
    audit_record.project_id = self.project_id
    audit_record.invoicing_milestone_id = self.invoicing_milestone_id
    audit_record.invoice_adder_type_id = self.invoice_adder_type_id
    audit_record.created_at = self.created_at
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.invoice_line_id = self.id
    audit_record.save
  end
end