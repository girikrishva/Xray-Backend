class VacationPoliciesAudit < ActiveRecord::Base
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id
  belongs_to :vacation_policy, class_name: 'VacationPolicy', foreign_key: :vacation_policy_id

  validates :vacation_code_id, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  validates :vacation_policy_id, presence: true

  def business_unit_name
    self.business_unit.name
  end
end