class PaymentHeader < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :payment_status, class_name: 'PaymentStatus', foreign_key: :payment_status_id

  has_many :payment_lines, class_name: 'PaymentLine'
  has_many :payment_headers_audits, class_name: 'PaymentHeadersAudit'

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :payment_date, presence: true
  validates :payment_status, presence: true
  validates :header_amount, presence: true

  validates_uniqueness_of :client_id, scope: [:client_id, :narrative, :payment_date]
  validates_uniqueness_of :narrative, scope: [:client_id, :narrative, :payment_date]
  validates_uniqueness_of :payment_date, scope: [:client_id, :narrative, :payment_date]

  after_create :create_audit_record
  after_update :create_audit_record

  def payment_header_name
    'Id: [' + self.id.to_s + '], Narrative: [' + self.narrative + '], Client: [' + self.client.name + '], Dated: [' + self.payment_date.to_s + '], Amount: [' + header_amount.to_s + '], Unreconciled: [' + self.unreconciled_amount.to_s + ']'
  end

  def unreconciled_amount
    self.header_amount - PaymentLine.where(payment_header_id: self.id).sum(:line_amount)
  end

  def create_audit_record
    audit_record = PaymentHeadersAudit.new
    audit_record.narrative = self.narrative
    audit_record.payment_date = self.payment_date
    audit_record.header_amount = self.header_amount
    audit_record.client_id = self.client_id
    audit_record.payment_status_id = self.payment_status_id
    audit_record.created_at = self.created_at
    audit_record.payment_header_id = self.id
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.save
  end

  def business_unit_name
    self.client.business_unit.name
  end
end