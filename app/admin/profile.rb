ActiveAdmin.register AdminUser, as: I18n.t('menu.profile') do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, label: I18n.t('menu.edit_profile'), parent: I18n.t('menu.security'), url: proc { '/admin/profiles/' + current_active_admin_user.id.to_s + '/edit' }, priority: 20

  config.clear_action_items!

  permit_params :email, :password, :password_confirmation, :role_id, :business_unit_id, :department_id, :designation_id

  action_item only: [:edit] do |resource|
    link_to I18n.t('label.back'), admin_dashboard_path
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    def update
      super do |format|
        redirect_to admin_dashboard_path and return if resource.valid?
      end
    end
  end

  form do |f|
    f.inputs I18n.t('label.admin_details') do
      if !f.object.new_record?
        f.input :email, input_html: {readonly: true}
      else
        f.input :email
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end

end
