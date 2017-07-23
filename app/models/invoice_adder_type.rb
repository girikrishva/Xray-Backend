class InvoiceAdderType < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :invoice_lines, class_name: 'InvoiceLine'

  default_scope { order(updated_at: :desc) }

  def invoice_adder_type_name
    'Id: [' + self.id.to_s + '], Name: [' + self.name + ']'
  end
end