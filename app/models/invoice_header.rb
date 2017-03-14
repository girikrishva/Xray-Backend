class InvoiceHeader < ActiveRecord::Base
  acts_as_paranoid

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

  def business_unit_name
    self.client.business_unit.name
  end

  def self.invoice_headers(as_on, due_status, completion_status)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    data = []
    if due_status.upcase == 'DUE' and completion_status.upcase == 'INCOMPLETE'
      InvoiceHeader.where('due_date <= ?', as_on).order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount > 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'COMPLETE'
      InvoiceHeader.where('due_date <= ?', as_on).order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount <= 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'DUE' and completion_status.upcase == 'ALL'
      InvoiceHeader.where('due_date <= ?', as_on).order('due_date').each do |ih|
        details = {}
        details['id'] = ih.id
        details['narrative'] = ih.narrative
        details['invoice_date'] = ih.invoice_date.to_s
        details['due_date'] = ih.due_date.to_s
        details['status'] = ih.invoice_status.name
        details['amount'] = format_currency(ih.header_amount)
        details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
        details['unpaid'] = format_currency(ih.unpaid_amount)
        details['client'] = ih.client.name
        details['business_unit'] = ih.client.business_unit.name
        data << details
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'INCOMPLETE'
      InvoiceHeader.where('due_date > ?', as_on).order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount > 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'COMPLETE'
      InvoiceHeader.where('due_date > ?', as_on).order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount <= 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'FUTURE' and completion_status.upcase == 'ALL'
      InvoiceHeader.where('due_date > ?', as_on).order('due_date').each do |ih|
        details = {}
        details['id'] = ih.id
        details['narrative'] = ih.narrative
        details['invoice_date'] = ih.invoice_date.to_s
        details['due_date'] = ih.due_date.to_s
        details['status'] = ih.invoice_status.name
        details['amount'] = format_currency(ih.header_amount)
        details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
        details['unpaid'] = format_currency(ih.unpaid_amount)
        details['client'] = ih.client.name
        details['business_unit'] = ih.client.business_unit.name
        data << details
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'INCOMPLETE'
      InvoiceHeader.all.order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount > 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'COMPLETE'
      InvoiceHeader.all.order('due_date').order('due_date').each do |ih|
        if ih.unpaid_amount <= 0
          details = {}
          details['id'] = ih.id
          details['narrative'] = ih.narrative
          details['invoice_date'] = ih.invoice_date.to_s
          details['due_date'] = ih.due_date.to_s
          details['status'] = ih.invoice_status.name
          details['amount'] = format_currency(ih.header_amount)
          details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
          details['unpaid'] = format_currency(ih.unpaid_amount)
          details['client'] = ih.client.name
          details['business_unit'] = ih.client.business_unit.name
          data << details
        end
      end
    elsif due_status.upcase == 'ALL' and completion_status.upcase == 'ALL'
      InvoiceHeader.all.order('due_date').each do |ih|
        details = {}
        details['id'] = ih.id
        details['narrative'] = ih.narrative
        details['invoice_date'] = ih.invoice_date.to_s
        details['due_date'] = ih.due_date.to_s
        details['status'] = ih.invoice_status.name
        details['amount'] = format_currency(ih.header_amount)
        details['paid'] = format_currency(ih.header_amount - ih.unpaid_amount)
        details['unpaid'] = format_currency(ih.unpaid_amount)
        details['client'] = ih.client.name
        details['business_unit'] = ih.client.business_unit.name
        data << details
      end
    end
    data
  end

  def self.invoice_header_details(invoice_header_id)
    data = []
    InvoiceLine.where('invoice_header_id = ?', invoice_header_id).order('id').each do |il|
      invoice_line = {}
      invoice_line['id'] = il.id
      invoice_line['narrative'] = il.narrative
      invoice_line['amount'] = format_currency(il.line_amount)
      invoice_line['paid'] = format_currency(il.line_amount - il.unpaid_amount)
      invoice_line['unpaid'] = format_currency(il.unpaid_amount)
      invoice_line['project'] = il.project.name
      invoice_line['invoicing_milestone'] = il.invoicing_milestone.name rescue nil
      invoice_line['adder_type'] = il.invoice_adder_type.name rescue nil
      data << invoice_line
    end
    data
  end
end