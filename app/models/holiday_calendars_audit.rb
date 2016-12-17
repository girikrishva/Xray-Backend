class HolidayCalendarsAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id

  validates :name, presence: true
  validates :as_on, presence: true
  validates :business_unit_id, presence: true
  validates :holiday_calendar_id, presence: true

  def business_unit_name
    self.business_unit.name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']'
  end
end
