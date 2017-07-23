class InvoiceTerm < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :invoice_headers, class_name: 'InvoiceHeader'

# default_scope { order(updated_at: :desc) }
end