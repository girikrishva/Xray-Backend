class HolidayCalendar < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id

  validates :name, presence: true
  validates :as_on, presence: true
  validates :business_unit_id, presence: true

  validates_uniqueness_of :name, scope: [:name, :as_on, :business_unit_id]
  validates_uniqueness_of :as_on, scope: [:name, :as_on, :business_unit_id]
  validates_uniqueness_of :business_unit_id, scope: [:name, :as_on, :business_unit_id]

  after_create :create_audit_record
  after_update :create_audit_record

  def create_audit_record
    audit_record = HolidayCalendarsAudit.new
    audit_record.business_unit = self.business_unit
    audit_record.name = self.name
    audit_record.description = self.description
    audit_record.as_on = self.as_on
    audit_record.comments = self.comments
    audit_record.updated_at = DateTime.now
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.holiday_calendar_id = self.id
    audit_record.save
  end

  def business_unit_name
    self.business_unit.name
  end

  def self.holidays_between(business_unit_id, start_date, end_date)
    HolidayCalendar.where('business_unit_id = ? and as_on between ? and ?', business_unit_id, start_date, end_date).count
  end
end
