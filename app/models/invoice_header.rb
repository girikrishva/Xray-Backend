class InvoiceHeader < ActiveRecord::Base
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :invoice_term, class_name: 'InvoiceTerm', foreign_key: :invoice_term_id
  belongs_to :invoice_status, class_name: 'InvoiceStatus', foreign_key: :invoice_status_id

  validates :client_id, presence: true
  validates :narrative, presence: true
  validates :invoice_date, presence: true
  validates :invoice_term_id, presence: true
  validates :invoice_status_id, presence: true

  validates_uniqueness_of :client_id, scope: [:client_id, :narrative, :invoice_date]
  validates_uniqueness_of :narrative, scope: [:client_id, :narrative, :invoice_date]
  validates_uniqueness_of :invoice_date, scope: [:client_id, :narrative, :invoice_date]

  before_create :populate_due_date
  before_update :populate_due_date

  def populate_due_date
    self.due_date = self.invoice_date + self.invoice_term.extra.to_f
  end

  def invoice_header_name
    '[' + self.id.to_s + '] [' + self.client.name + '] [' + self.narrative + '] [' + self.invoice_date.to_s + ']'
  end
end