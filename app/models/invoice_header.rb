class InvoiceHeader < ActiveRecord::Base
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :invoice_term, class_name: 'InvoiceTerm', foreign_key: :invoice_term_id
  belongs_to :invoice_status, class_name: 'InvoiceStatus', foreign_key: :invoice_status_id

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :invoice_date, presence: true
  validates :invoice_term_id, presence: true
  validates :invoice_status_id, presence: true
  validates :header_amount, presence: true

  validates_uniqueness_of :client_id, scope: [:client_id, :narrative, :invoice_date]
  validates_uniqueness_of :narrative, scope: [:client_id, :narrative, :invoice_date]
  validates_uniqueness_of :invoice_date, scope: [:client_id, :narrative, :invoice_date]

  before_create :populate_due_date
  before_update :populate_due_date

  has_many :invoice_lines, class_name: 'InvoiceLine'
  has_many :payment_lines, class_name: 'PaymentLine '
  has_many :invoice_headers_audits, class_name: 'InvoiceHeadersAudit'

  after_create :create_audit_record
  after_update :create_audit_record

  def populate_due_date
    invoice_term = InvoiceTerm.find(self.invoice_term.id)
    extra = JSON.parse(invoice_term.extra)
    self.due_date = self.invoice_date + extra['credit_days'].to_f
  end

  def name
    self.invoice_header_name
  end

  def invoice_header_name
    'Id: [' + self.id.to_s + '], Narrative: [' + self.narrative + '], Client: [' + self.client.name + '], Dated: [' + self.invoice_date.to_s + '], Amount: [' + self.header_amount.to_s + '], Unpaid: [' + self.unpaid_amount.to_s + ']'
  end

  def unpaid_amount
    unpaid_amount = 0
    InvoiceLine.where(invoice_header_id: self.id).each do |invoice_line|
      unpaid_amount += invoice_line.unpaid_amount
    end
    unpaid_amount
  end

  def self.invoice_headers_for_client(payment_header_id)
    payment_header = PaymentHeader.find(payment_header_id)
    InvoiceHeader.where(client_id: payment_header.client_id).order('invoice_date desc')
  end

  def create_audit_record
    audit_record = InvoiceHeadersAudit.new
    audit_record.narrative = self.narrative
    audit_record.invoice_date = self.invoice_date
    audit_record.due_date = self.due_date
    audit_record.header_amount = self.header_amount
    audit_record.client_id = self.client_id
    audit_record.invoice_status_id = self.invoice_status_id
    audit_record.invoice_term_id = self.invoice_term_id
    audit_record.created_at = self.created_at
    audit_record.invoice_header_id = self.id
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.save
  end
end