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
end