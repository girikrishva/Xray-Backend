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
  has_many :vacation_policies_audits, class_name: 'VacationPoliciesAudit'

  default_scope { order(updated_at: :desc) }

  def self.fiscal_year_start_date(business_unit_id, year = Date.today.year)
    business_unit = BusinessUnit.find(business_unit_id)
    extra = JSON.parse(business_unit.extra)
    x = '01' + '-' + extra['fiscal_year_start'] + '-' + year.to_s
    Date.parse('01' + '-' + extra['fiscal_year_start'] + '-' + year.to_s)
  end

  def self.fiscal_year_end_date(business_unit_id, year = Date.today.year)
    BusinessUnit.fiscal_year_start_date(business_unit_id, year) + 1.year - 1
  end
end