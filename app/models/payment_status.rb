class PaymentStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :payment_headers, class_name: 'PaymentHeader'
end