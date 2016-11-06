class MakeLookupTypesColumnsNotNull < ActiveRecord::Migration
  def change
    change_column_null :lookup_types, :name, false
  end
end
