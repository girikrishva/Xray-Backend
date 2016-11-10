ActiveAdmin.register AdminUser do
  menu label: 'Define Users', parent: 'Security', priority: 10

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_admin_user_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_admin_users_path
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
      if !f.object.new_record?
        f.input :email, input_html: {readonly: true}
      else
        f.input :email
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end

end
