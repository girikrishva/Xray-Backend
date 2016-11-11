class AddAdminUsersToRolesFk < ActiveRecord::Migration
  def change
    add_reference :admin_users, :role, index: true, foreign_key: true, null: false
  end
end
