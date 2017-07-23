class VacationCode < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacation_policies, class_name: 'VacationPolicy'
  has_many :vacations, class_name: 'Vacation'
  has_many :vacation_policies_audits, class_name: 'VacationPoliciesAudit'

# default_scope { order(updated_at: :desc) }
end