class Vacation < ActiveRecord::Base
  belongs_to :user, :class_name => 'AdminUser', :foreign_key => :admin_user_id
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :approval_status, :class_name => 'ApprovalStatus', :foreign_key => :approval_status_id

  validates :admin_user_id, presence: true
  validates :request_date, presence: true
  validates :narrative, presence: true
  validates :vacation_code_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :hours_per_day, presence: true
  validates :approval_status_id, presence: true

  before_create :date_check
  before_create :request_validity_check

  def request_validity_check
    Vacation.where('admin_user_id = ? and approval_status_id != ?', self.admin_user_id, ApprovalStatus.where(name: I18n.t('label.canceled')).first.id).each do |v|
      if (self.id != v.id) and (self.start_date >= v.start_date and self.start_date <= v.end_date) or (self.end_date >= v.start_date and self.end_date <= v.end_date)
        raise I18n.t('errors.request_validity_check_error')
      end
    end
    return true
  end

  def date_check
    if self.start_date > self.end_date
      raise I18n.t('errors.date_check')
    end
  end

  def approval_status_name
    self.approval_status.name
  end

  def eligible_days
    Vacation.eligible_days(self.user.id, self.vacation_code.id, self.start_date)
  end

  def holidays
    Vacation.holidays(self.user.id, self.start_date)
  end

  def availed_days
    Vacation.availed_days(self.user.id, self.vacation_code.id, self.start_date)
  end

  def balance_days
    self.eligible_days + self.holidays - self.availed_days
  end

  def requested_days
    ((((self.end_date - self.start_date + 1) * 8) / 8) * 2).round / 2.0
  end

  def self.eligible_days(admin_user_id, vacation_code_id, start_date = Date.today)
    admin_user = AdminUser.find(admin_user_id)
    days_allowed = VacationPolicy.latest_days_allowed(admin_user.business_unit_id, vacation_code_id, start_date)
    fiscal_year_start_date = BusinessUnit.fiscal_year_start_date(admin_user.business_unit_id, start_date)
    fiscal_year_end_date = BusinessUnit.fiscal_year_end_date(admin_user.business_unit_id, start_date.year)
    from_date = (admin_user.date_of_joining >= fiscal_year_start_date) ? admin_user.date_of_joining : fiscal_year_start_date
    if !admin_user.date_of_leaving.blank?
      to_date = (admin_user.date_of_leaving < fiscal_year_end_date) ? admin_user.date_of_leaving : fiscal_year_end_date
    else
      to_date = start_date
    end
    days_in_year = fiscal_year_end_date - fiscal_year_start_date + 25
    days_employed_till_start_date = to_date - from_date + 1
    eligible_days = (((days_employed_till_start_date / days_in_year) * days_allowed * 2).round / 2.0)
  end

  def self.availed_days(admin_user_id, vacation_code_id, start_date = Date.today)
    admin_user = AdminUser.find(admin_user_id)
    availed_hours = 0
    Vacation.where('admin_user_id = ? and vacation_code_id = ? and end_date < ? and approval_status_id = ?', admin_user.id, vacation_code_id, start_date, ApprovalStatus.where(name: I18n.t('label.approved')).first.id).each do |vacation|
      availed_hours += (vacation.end_date - vacation.start_date + 1) * vacation.hours_per_day
    end
    fiscal_year_start_date = BusinessUnit.fiscal_year_start_date(admin_user.business_unit_id, start_date)
    fiscal_year_end_date = BusinessUnit.fiscal_year_end_date(admin_user.business_unit_id, start_date.year)
    from_date = (admin_user.date_of_joining >= fiscal_year_start_date) ? admin_user.date_of_joining : fiscal_year_start_date
    if !admin_user.date_of_leaving.blank?
      to_date = (admin_user.date_of_leaving < fiscal_year_end_date) ? admin_user.date_of_leaving : fiscal_year_end_date
    else
      to_date = start_date
    end
    availed_days = (((availed_hours / 8) * 2).round / 2.0)
  end

  def self.holidays(admin_user_id, start_date = Date.today)
    admin_user = AdminUser.find(admin_user_id)
    fiscal_year_start_date = BusinessUnit.fiscal_year_start_date(admin_user.business_unit_id, start_date)
    fiscal_year_end_date = BusinessUnit.fiscal_year_end_date(admin_user.business_unit_id, start_date.year)
    from_date = (admin_user.date_of_joining >= fiscal_year_start_date) ? admin_user.date_of_joining : fiscal_year_start_date
    if !admin_user.date_of_leaving.blank?
      to_date = (admin_user.date_of_leaving < fiscal_year_end_date) ? admin_user.date_of_leaving : fiscal_year_end_date
    else
      to_date = start_date
    end
    (HolidayCalendar.holidays_between(admin_user.business_unit_id, from_date, to_date) * 2).round / 2.0
  end
end