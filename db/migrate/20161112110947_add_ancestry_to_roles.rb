class AddAncestryToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :ancestry, :string
    add_index :roles, :ancestry
  end

  def down
    remove_column :roles, :ancestry
    remove_index :roles, :ancestry
  end
end
