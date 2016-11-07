class CreateVacationReasons < ActiveRecord::Migration
  def change
    create_table :vacation_reasons do |t|
      t.string :code, null: false
      t.string :description
      t.date :as_on, null: false
      t.boolean :paid, null: false
      t.float :days_allowed, null: false
      t.string :comments
    end
  end

  def self.down
    drop_table :vacation_reasons
  end
end
