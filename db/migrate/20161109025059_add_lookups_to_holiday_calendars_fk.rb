class AddLookupsToHolidayCalendarsFk < ActiveRecord::Migration
  def change
    add_reference :holiday_calendars, :business_unit, references: :lookups, index: true, foreign_key: true, null: false
  end
end
