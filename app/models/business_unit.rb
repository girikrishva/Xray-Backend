class BusinessUnit < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :vacation_policies, class_name: 'VacationPolicy'
  has_many :holiday_calendars, class_name: 'HolidayCalendar'
  has_many :project_types, class_name: 'ProjectType'
  has_many :admin_users, class_name: 'AdminUser'
  has_many :admin_users_audits, class_name: 'AdminUserAudit'
  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'
end