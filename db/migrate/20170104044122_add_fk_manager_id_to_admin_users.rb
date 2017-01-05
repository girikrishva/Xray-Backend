class AddFkManagerIdToAdminUsers < ActiveRecord::Migration
  def change
    add_reference :admin_users, :admin_user, index:true, foreign_key: true
    rename_column :admin_users, :admin_user_id, :manager_id
  end
end
