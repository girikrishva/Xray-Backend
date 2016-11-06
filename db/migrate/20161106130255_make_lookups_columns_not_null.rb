class MakeLookupsColumnsNotNull < ActiveRecord::Migration
  def change
    change_column_null :lookups, :value, false
    change_column_null :lookups, :rank, false
    change_column_null :lookups, :lookup_type_id, false
  end
end
