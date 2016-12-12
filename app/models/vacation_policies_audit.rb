class VacationPoliciesAudit < ActiveRecord::Base
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id
  belongs_to :vacation_policy, class_name: 'VacationPolicy', foreign_key: :vacation_policy_id
end