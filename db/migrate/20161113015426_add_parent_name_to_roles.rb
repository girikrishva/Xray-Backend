class AddParentNameToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :parent_name, :string
  end
end
