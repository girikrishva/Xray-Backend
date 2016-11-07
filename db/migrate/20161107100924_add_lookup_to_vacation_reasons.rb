class AddLookupToVacationReasons < ActiveRecord::Migration
  def change
    add_reference :vacation_reasons, :lookup, index: true, foreign_key: true
  end
end
