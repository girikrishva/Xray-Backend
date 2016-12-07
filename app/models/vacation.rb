class Vacation < ActiveRecord::Base
  belongs_to :user, :class_name => 'AdminUser', :foreign_key => :admin_user_id
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :approval_status, :class_name => 'FlagStatus', :foreign_key => :approval_status_id

  validates :admin_user_id, presence: true
  validates :request_date, presence: true
  validates :narrative, presence: true
  validates :vacation_code_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :hours_per_day, presence: true
  validates :approval_status_id, presence: true

  before_create :request_validity_check
  before_update :request_validity_check

  def request_validity_check
    Vacation.where(admin_user_id: self.admin_user_id, vacation_code_id: self.vacation_code_id).each do |v|
      if (self.id != v.id) and (self.start_date >= v.start_date and self.start_date <= v.end_date) or (self.end_date >= v.start_date and self.end_date <= v.end_date)
        raise I18n.t('errors.request_validity_check_error')
      end
    end
    return true
  end
end