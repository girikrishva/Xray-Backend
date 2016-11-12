ActiveAdmin.register AdminUser do
  menu if: proc { is_authorized? ["Administrator"] }, label: 'Define Users', parent: 'Security', priority: 10

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_admin_user_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_admin_users_path
  end

  permit_params :email, :password, :password_confirmation, :role_id

  config.sort_order = 'email_asc'

  index do
    selectable_column
    column :id
    column :email
    column :role, sortable: 'roles.name' do |resource|
      resource.role.name
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions defaults: true, dropdown: true do |resource|
      item "Assign Role", edit_admin_admin_user_path(id: resource.id, suppress_password: true)
    end
  end

  controller do
    def scoped_action
      AdminUser.includes(:role)
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
  filter :role
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
      if params.has_key?(:suppress_password) and params[:suppress_password]
        if is_authorized?(["Administrator"])
          f.input :role
        end
      else
        f.input :password
        f.input :password_confirmation
        if is_authorized?(["Administrator"])
          f.input :role
        end
      end
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end

end
