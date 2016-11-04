class AddLookupTypeToLookups < ActiveRecord::Migration
  def change
    add_reference :lookups, :lookup_type, index: true, foreign_key: true
  end
end
