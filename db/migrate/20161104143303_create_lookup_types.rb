class CreateLookupTypes < ActiveRecord::Migration
  def change
    create_table :lookup_types do |t|
      t.string :name
      t.string :description
      t.string :comments
    end
  end
end
