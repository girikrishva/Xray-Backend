class MakeVacationReasonsColumnsNotNull < ActiveRecord::Migration
  def change
    change_column_null :vacation_reasons, :lookup_id, false
  end
end
