class AddSuperAdminToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :super_admin, :boolean
  end
end
