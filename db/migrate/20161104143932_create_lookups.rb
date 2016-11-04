class CreateLookups < ActiveRecord::Migration
  def change
    create_table :lookups do |t|
      t.string :value
      t.string :description
      t.float :rank
      t.string :comments
    end
  end
end
