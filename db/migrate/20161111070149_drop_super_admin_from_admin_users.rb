class DropSuperAdminFromAdminUsers < ActiveRecord::Migration
  def change
    remove_column :admin_users, :super_admin
  end
end
