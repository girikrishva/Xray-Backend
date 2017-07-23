class InvoiceLinesAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :invoice_line, class_name: 'InvoiceLine', foreign_key: :invoice_line_id
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :invoicing_milestone, class_name: 'InvoicingMilestone', foreign_key: :invoicing_milestone_id
  belongs_to :invoice_adder_type, class_name: 'InvoiceAdderType', foreign_key: :invoice_adder_type_id

  validates :invoice_header_id, presence: true
  validates :project_id, presence: true
  validates :narrative, presence: true
  validates :line_amount, presence: true

# default_scope { order(updated_at: :desc) }

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']' rescue nil
  end

  def invoice_line_name
    self.invoice_line.invoice_line_name
  end

  def unpaid_amount
    payment_lines = PaymentLine.where(invoice_line_id: self.invoice_line_id)
    total_line_amount = 0
    payment_lines.each do |payment_line|
      if payment_line.payment_header.payment_date < self.updated_at + 1
        total_line_amount += payment_line.line_amount
      end
    end
    self.line_amount - total_line_amount
  end
end