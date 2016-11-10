class BusinessUnit < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacation_policies, class_name: 'VacationPolicy'
  has_many :holiday_calendars, class_name: 'HolidayCalendar'
end