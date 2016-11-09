class CreateHolidayCalendar < ActiveRecord::Migration
  def change
    create_table :holiday_calendars do |t|
      t.string :name, nullable: false
      t.date :as_on, nullable:false
      t.string :description
      t.string :comments
    end
  end
end
