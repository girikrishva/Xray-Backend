class InvoiceHeadersAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :invoice_term, class_name: 'InvoiceTerm', foreign_key: :invoice_term_id
  belongs_to :invoice_status, class_name: 'InvoiceStatus', foreign_key: :invoice_status_id
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :invoice_date, presence: true
  validates :invoice_term_id, presence: true
  validates :invoice_status_id, presence: true
  validates :header_amount, presence: true
  validates :invoice_header_id, presence: true

# default_scope { order(updated_at: :desc) }

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']' rescue nil
  end

  def invoice_header_name
    self.invoice_header.invoice_header_name
  end

  def unpaid_amount
    unpaid_amount = 0
    InvoiceLinesAudit.where(invoice_header_id: self.invoice_header_id).each do |invoice_line_audit|
      if invoice_line_audit.invoice_header.invoice_date <= self.updated_at
        unpaid_amount += invoice_line_audit.unpaid_amount
      end
    end
    unpaid_amount
  end
end