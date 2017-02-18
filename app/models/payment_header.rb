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

  def self.payment_headers(as_on, due_status, completion_status)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    data = []
    if due_status.upcase == 'DUE' and completion_status.upcase == 'INCOMPLETE'
      PaymentHeader.where('payment_date <= ?', as_on).order('payment_date').each do |ph|
        if ph.unreconciled_amount > 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'COMPLETE'
      PaymentHeader.where('payment_date <= ?', as_on).order('payment_date').each do |ph|
        if ph.unreconciled_amount <= 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'ALL'
      PaymentHeader.where('payment_date <= ?', as_on).order('payment_date').each do |ph|
        details = {}
        details['id'] = ph.id
        details['narrative'] = ph.narrative
        details['payment_date'] = ph.payment_date.to_s
        details['status'] = ph.payment_status.name
        details['amount'] = ph.header_amount
        details['reconciled'] = ph.header_amount - ph.unreconciled_amount
        details['unreconciled'] = ph.unreconciled_amount
        details['client'] = ph.client.name
        details['business_unit'] = ph.client.business_unit.name
        data << details
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'INCOMPLETE'
      PaymentHeader.where('payment_date > ?', as_on).order('payment_date').each do |ph|
        if ph.unreconciled_amount > 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'COMPLETE'
      PaymentHeader.where('payment_date > ?', as_on).order('payment_date').each do |ph|
        if ph.unreconciled_amount <= 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'ALL'
      PaymentHeader.where('payment_date > ?', as_on).order('payment_date').each do |ph|
        details = {}
        details['id'] = ph.id
        details['narrative'] = ph.narrative
        details['payment_date'] = ph.payment_date.to_s
        details['status'] = ph.payment_status.name
        details['amount'] = ph.header_amount
        details['reconciled'] = ph.header_amount - ph.unreconciled_amount
        details['unreconciled'] = ph.unreconciled_amount
        details['client'] = ph.client.name
        details['business_unit'] = ph.client.business_unit.name
        data << details
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'INCOMPLETE'
      PaymentHeader.all.order('payment_date').each do |ph|
        if ph.unreconciled_amount > 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'COMPLETE'
      PaymentHeader.all.order('payment_date').each do |ph|
        if ph.unreconciled_amount <= 0
          details = {}
          details['id'] = ph.id
          details['narrative'] = ph.narrative
          details['payment_date'] = ph.payment_date.to_s
          details['status'] = ph.payment_status.name
          details['amount'] = ph.header_amount
          details['reconciled'] = ph.header_amount - ph.unreconciled_amount
          details['unreconciled'] = ph.unreconciled_amount
          details['client'] = ph.client.name
          details['business_unit'] = ph.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'ALL'
      PaymentHeader.all.order('payment_date').each do |ph|
        details = {}
        details['id'] = ph.id
        details['narrative'] = ph.narrative
        details['payment_date'] = ph.payment_date.to_s
        details['status'] = ph.payment_status.name
        details['amount'] = ph.header_amount
        details['reconciled'] = ph.header_amount - ph.unreconciled_amount
        details['unreconciled'] = ph.unreconciled_amount
        details['client'] = ph.client.name
        details['business_unit'] = ph.client.business_unit.name
        data << details
      end
    end
    data
  end

  def self.payment_header_details(payment_header_id)
    data = []
    PaymentLine.where('payment_header_id = ?', payment_header_id).order('id').each do |pl|
      payment_line = {}
      payment_line['id'] = pl.id
      payment_line['narrative'] = pl.narrative
      payment_line['amount'] = pl.line_amount
      payment_line['invoice_line_id'] = pl.invoice_line.id
      payment_line['invoice_line_narrative'] = pl.invoice_line.narrative
      payment_line['invoice_header_id'] = pl.invoice_line.invoice_header.id
      payment_line['invoice_header_narrative'] = pl.invoice_line.invoice_header.narrative
      payment_line['project'] = pl.invoice_line.project.name
      data << payment_line
    end
    data
  end
end