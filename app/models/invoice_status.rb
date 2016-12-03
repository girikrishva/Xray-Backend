class InvoiceStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :invoice_headers, class_name: 'InvoiceHeader'
end