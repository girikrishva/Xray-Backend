class ApprovalStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacations, class_name: 'Vacation'
  has_many :timesheets, class_name: 'Timesheet'
end