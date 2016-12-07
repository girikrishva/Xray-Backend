class PaymentHeader < ActiveRecord::Base
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :payment_status, class_name: 'PaymentStatus', foreign_key: :payment_status_id

  has_many :payment_lines, class_name: 'PaymentLine'

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :payment_date, presence: true
  validates :payment_status, presence: true
  validates :header_amount, presence: true

  validates_uniqueness_of :client_id, scope: [:client_id, :narrative, :payment_date]
  validates_uniqueness_of :narrative, scope: [:client_id, :narrative, :payment_date]
  validates_uniqueness_of :payment_date, scope: [:client_id, :narrative, :payment_date]

  def payment_header_name
    'Id: [' + self.id.to_s + '], Narrative: [' + self.narrative + '], Client: [' + self.client.name + '], Dated: [' + self.payment_date.to_s + '], Amount: [' + header_amount.to_s + '], Unreconciled: [' + self.unreconciled_amount.to_s + ']'
  end

  def unreconciled_amount
    self.header_amount - PaymentLine.where(payment_header_id: self.id).sum(:line_amount)
  end
end