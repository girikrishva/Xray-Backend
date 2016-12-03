class InvoiceAdderType < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :invoice_lines, class_name: 'InvoiceLine'
end