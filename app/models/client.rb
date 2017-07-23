class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id

  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'
  has_many :client_audits, class_name: 'ClientsAudit'

  validates :business_unit_id, presence: true
  validates :name, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :name]
  validates_uniqueness_of :name, scope: [:business_unit_id, :name]

  after_create :create_audit_record
  before_update :create_audit_record

  default_scope { order(updated_at: :desc) }

  def create_audit_record
    audit_record = ClientsAudit.new
    audit_record.business_unit = self.business_unit
    audit_record.name = self.name
    audit_record.contact_name = self.contact_name
    audit_record.contact_email = self.contact_email
    audit_record.contact_phone = self.contact_phone
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.client_id = self.id
    audit_record.save
  end

  def client_name
    self.name + ' [' + self.business_unit_name + ']'
  end

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def self.ordered_lookup
    Client.all.order(:name)
  end
end