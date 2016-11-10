class VacationCode < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacation_policies, class_name: 'VacationPolicy'
end