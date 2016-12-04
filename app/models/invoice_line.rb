class InvoiceLine < ActiveRecord::Base
  belongs_to :invoice_header, class_name: 'InvoiceHeader', foreign_key: :invoice_header_id
  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :invoicing_milestone, class_name: 'InvoicingMilestone', foreign_key: :invoicing_milestone_id
  belongs_to :invoice_adder_type, class_name: 'InvoiceAdderType', foreign_key: :invoice_adder_type_id

  validates :invoice_header_id, presence: true
  validates :project_id, presence: true
  validates :narrative, presence: true
  validates :line_amount, presence: true

  validates_uniqueness_of :invoice_header_id, scope: [:invoice_header_id, :project_id, :narrative]
  validates_uniqueness_of :project_id, scope: [:invoice_header_id, :project_id, :narrative]
  validates_uniqueness_of :narrative, scope: [:invoice_header_id, :project_id, :narrative]

  before_create :invoicing_milestone_invoice_adder_type_arc_check
  before_update :invoicing_milestone_invoice_adder_type_arc_check

  def invoice_header_name
    self.invoice_header.invoice_header_name
  end

  def invoicing_milestone_invoice_adder_type_arc_check
    if self.invoicing_milestone_id.blank? and self.invoice_adder_type_id.blank?
      raise I18n.t('errors.invoicing_milestone_invoice_adder_type_arc_error')
    end
  end
end