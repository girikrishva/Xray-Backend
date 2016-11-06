ActiveAdmin.register AdminUser do
  menu label: 'Manage Users', parent: 'Security', priority: 10

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_admin_user_path
  end

  permit_params :email, :password, :password_confirmation

  config.sort_order = 'email_asc'

  index do
    selectable_column
    column :id
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions defaults: true, dropdown: true
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
