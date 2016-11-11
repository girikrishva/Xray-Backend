class CreateRole < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :description
      t.float :rank
      t.string :comments
    end
  end
end
