class AddCols < ActiveRecord::Migration
  def change
    add_column :admin_users, :comments, :string
    add_column :admin_users_audits, :comments, :string
  end
end
