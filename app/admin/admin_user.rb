ActiveAdmin.register AdminUser do
  menu if: proc { is_menu_authorized? [I18n.t('role.administrator')] }, label: I18n.t('menu.define_users'), parent: I18n.t('menu.security'), priority: 10

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_admin_user_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), admin_admin_users_path
  end

  batch_action :activate do |ids|
    ids.each do |id|
      admin_user = AdminUser.find(id)
      admin_user.active = true
      admin_user.save
    end
    redirect_to collection_url
  end

  batch_action :deactivate do |ids|
    ids.each do |id|
      admin_user = AdminUser.find(id)
      admin_user.active = false
      admin_user.save
    end
    redirect_to collection_url
  end

  permit_params :email, :password, :password_confirmation, :role_id, :business_unit_id, :department_id, :designation_id, :active, :date_of_joining, :date_of_leaving

  config.sort_order = 'email_asc'

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :email
    column :name
    column :active
    column :role, sortable: 'roles.name' do |resource|
      resource.role.name
    end
    column :department, sortable: 'departments.name' do |resource|
      resource.department.name
    end
    column :designation, sortable: 'designations.name' do |resource|
      resource.designation.name
    end
    column :date_of_joining
    column :date_of_leaving
    actions defaults: true, dropdown: true do |resource|
      item I18n.t('actions.change_qualifiers'), edit_admin_admin_user_path(id: resource.id, suppress_password: true)
      item I18n.t('actions.audit_trail'), admin_admin_users_audits_path(admin_user_id: resource.id)
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.administrator')])
    end

    def scoped_action
      AdminUser.includes [:role, :business_unit, :department, :designation]
    end

    def create
      super do |format|
        redirect_to collection_url and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url and return if resource.valid?
      end
    end
  end

  filter :business_unit
  filter :email
  filter :name
  filter :active
  filter :date_of_joining
  filter :date_of_leaving
  filter :role
  filter :department
  filter :designation

  form do |f|
    f.inputs I18n.t('label.admin_details') do
      if !f.object.new_record?
        f.input :email, input_html: {readonly: true}
      else
        f.input :email
      end
      if params.has_key?(:suppress_password) and params[:suppress_password]
        f.input :name, required: true
        f.input :active, required: true
        f.input :date_of_joining, required: true, as: :datepicker
        f.input :date_of_leaving, as: :datepicker
        f.input :role, required: true
        f.input :business_unit, required: true
        f.input :department, required: true
        f.input :designation, required: true
      else
        f.input :password
        f.input :password_confirmation
        if f.object.new_record?
          f.input :name, required: true
          f.input :active
          f.input :date_of_joining, required: true, as: :datepicker
          f.input :date_of_leaving, as: :datepicker
          f.input :role, required: true
          f.input :business_unit, required: true
          f.input :department, required: true
          f.input :designation, required: true
        end
      end
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
      f.cancel_link
    end
  end

end
