class PaymentHeadersAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :payment_status, class_name: 'PaymentStatus', foreign_key: :payment_status_id
  belongs_to :payment_header, class_name: 'PaymentHeader', foreign_key: :payment_header_id

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :payment_date, presence: true
  validates :payment_status, presence: true
  validates :header_amount, presence: true
  validates :payment_header_id, presence: true

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']'
  end

  def payment_header_name
    self.payment_header.payment_header_name
  end

  def unreconciled_amount
    self.header_amount - PaymentLine.where('payment_header_id = ? and created_at < ?', self.payment_header_id, self.payment_date + 1).sum(:line_amount)
  end
end