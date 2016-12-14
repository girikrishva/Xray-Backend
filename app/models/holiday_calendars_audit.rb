class HolidayCalendarsAudit < ActiveRecord::Base
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id

  validates :name, presence: true
  validates :as_on, presence: true
  validates :business_unit_id, presence: true
  validates :holiday_calendar_id, presence: true

  def business_unit_name
    self.business_unit.name
  end
end
