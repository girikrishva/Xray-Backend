ActiveAdmin.register AdminUser do
  menu if: proc { is_menu_authorized? ["Administrator"] }, label: 'Define Users', parent: 'Security', priority: 10

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_admin_user_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_admin_users_path
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

  permit_params :email, :password, :password_confirmation, :role_id, :business_unit_id, :department_id, :designation_id, :active

  config.sort_order = 'email_asc'

  index do
    selectable_column
    column :id
    column :email
    column :active
    column :role, sortable: 'roles.name' do |resource|
      resource.role.name
    end
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :department, sortable: 'departments.name' do |resource|
      resource.department.name
    end
    column :designation, sortable: 'designations.name' do |resource|
      resource.designation.name
    end
    actions defaults: true, dropdown: true do |resource|
      item "Change Qualifiers", edit_admin_admin_user_path(id: resource.id, suppress_password: true)
      item "Audit Trail", admin_admin_users_audits_path(admin_user_id: resource.id)
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Administrator"])
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

  filter :email
  filter :active
  filter :role
  filter :business_unit
  filter :department
  filter :designation

  form do |f|
    f.inputs "Admin Details" do
      if !f.object.new_record?
        f.input :email, input_html: {readonly: true}
      else
        f.input :email
      end
      if params.has_key?(:suppress_password) and params[:suppress_password]
        f.input :active
        f.input :role
        f.input :business_unit
        f.input :department
        f.input :designation
      else
        f.input :password
        f.input :password_confirmation
        if f.object.new_record?
          f.input :active
          f.input :role
          f.input :business_unit
          f.input :department
          f.input :designation
        end
      end
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end

end
