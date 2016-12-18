class PaymentLine < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :payment_header, class_name: 'PaymentHeader', foreign_key: :payment_header_id
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :invoice_line, class_name: 'InvoiceLine', foreign_key: :invoice_line_id

  validates :payment_header_id, presence: true
  validates :invoice_header_id, presence: true
  validates :invoice_line_id, presence: true
  validates :narrative, presence: true
  validates :line_amount, presence: true

  validates_uniqueness_of :payment_header_id, scope: [:payment_header_id, :invoice_line_id]
  validates_uniqueness_of :invoice_line_id, scope: [:payment_header_id, :invoice_line_id]

  after_create :create_audit_record
  after_update :create_audit_record

  def payment_header_name
    self.payment_header.payment_header_name
  end

  def payment_line_name
    'Id: [' + self.id.to_s + '], Narrative: [' + self.narrative + '], Amount: [' + self.line_amount.to_s + ']'
  end

  def create_audit_record
    audit_record = PaymentLinesAudit.new
    audit_record.narrative = self.narrative
    audit_record.line_amount = self.line_amount
    audit_record.payment_header_id = self.payment_header_id
    audit_record.invoice_header_id = self.invoice_header_id
    audit_record.invoice_line_id = self.invoice_line_id
    audit_record.created_at = self.created_at
    audit_record.payment_line_id = self.id
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.save
  end
end