class VacationPolicy < ActiveRecord::Base
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id

  has_many :vacation_policies_audits, class_name: 'VacationPolicyAudit'

  validates :vacation_code_id, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  # validates :business_unit_id, presence: true

  # validates_uniqueness_of :business_unit, scope: [:vacation_code, :as_on]
  validates_uniqueness_of :vacation_code, scope: [:business_unit, :as_on]

  after_create :create_audit_record
  after_update :create_audit_record

  def create_audit_record
    audit_record = VacationPoliciesAudit.new
    audit_record.vacation_code_id = self.vacation_code_id
    audit_record.description = self.description
    audit_record.as_on = self.as_on
    audit_record.paid = self.paid
    audit_record.days_allowed = self.days_allowed
    audit_record.comments = self.comments
    audit_record.business_unit_id = self.business_unit_id
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.vacation_policy_id = self.id
    audit_record.save
  end

  def business_unit_name
    self.business_unit.name
  end

  def self.latest_days_allowed(business_unit_id, vacation_code_id, as_on)
    VacationPolicy.where('business_unit_id = ? and vacation_code_id = ? and as_on <= ?', business_unit_id, vacation_code_id, as_on).order('as_on desc').first.days_allowed
  end
end