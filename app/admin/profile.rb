ActiveAdmin.register AdminUser, as: 'Profile' do
  menu if: proc { is_menu_authorized? ["User"] }, label: 'Edit Profile', parent: 'Security', url: proc { '/admin/profiles/' + current_active_admin_user.id.to_s + '/edit' }, priority: 20

  config.clear_action_items!

  permit_params :email, :password, :password_confirmation, :role_id, :business_unit_id, :department_id, :designation_id

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["User"])
    end

    def update
      super do |format|
        redirect_to admin_dashboard_path and return if resource.valid?
      end
    end
  end

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
      f.cancel_link(admin_dashboard_path)
    end
  end

end
