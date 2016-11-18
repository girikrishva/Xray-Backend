ActiveAdmin.register AdminUsersAudit do
  menu false

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "Back", admin_admin_users_path
  end

  config.sort_order = 'id_desc'

  index do
    selectable_column
    column :id
    column :email
    column :name
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
    column :created_at
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Administrator"])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:admin_user_id)
        redirect_to admin_admin_users_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"admin_user_id_eq" => params[:admin_user_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_action
      AdminUser.includes [:role, :business_unit, :department, :designation]
    end
  end

  filter :email
  filter :name
  filter :active
  filter :role
  filter :business_unit
  filter :department
  filter :designation
end
