class PaymentLinesAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :payment_header, class_name: 'PaymentHeader', foreign_key: :payment_header_id
  belongs_to :payment_line, class_name: 'PaymentLine', foreign_key: :payment_line_id
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :invoice_line, class_name: 'InvoiceLine', foreign_key: :invoice_line_id

  validates :payment_header_id, presence: true
  validates :payment_line_id, presence: true
  validates :invoice_header_id, presence: true
  validates :invoice_line_id, presence: true
  validates :narrative, presence: true
  validates :line_amount, presence: true

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']'
  end

  def payment_line_name
    self.payment_line.payment_line_name
  end
end