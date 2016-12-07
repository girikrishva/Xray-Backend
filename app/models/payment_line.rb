class PaymentLine < ActiveRecord::Base
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

  def payment_header_name
    self.payment_header.payment_header_name
  end
end