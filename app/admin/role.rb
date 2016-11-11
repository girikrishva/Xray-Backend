ActiveAdmin.register Role do
  menu label: 'Define Roles', parent: 'Security', priority: 30

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  permit_params  :name, :description, :rank, :comments

  config.sort_order = 'rank_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_role_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_roles_path
  end

  index do
    selectable_column
    column :id
    column :name
    column :description
    column :rank
    column :comments
    actions defaults: true  , dropdown: true do |resource|
    end
  end

  filter :name
  filter :description
  filter :rank
  filter :comments

  controller do
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

  form do |f|
    if f.object.rank.blank?
      f.object.rank = Role.generate_next_rank
    end
    f.inputs
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
