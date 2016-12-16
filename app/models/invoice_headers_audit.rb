class InvoiceHeadersAudit < ActiveRecord::Base
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

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']'
  end

  def invoice_header_name
    self.invoice_header.invoice_header_name
  end
end