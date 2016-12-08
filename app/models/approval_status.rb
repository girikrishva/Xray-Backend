class ApprovalStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacations, class_name: 'Vacation'
end