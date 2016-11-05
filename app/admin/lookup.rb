ActiveAdmin.register Lookup do
  menu label: 'Lookups', parent: 'Masters', priority: 20

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

  permit_params :value, :description, :rank, :comments, :lookup_type_id

  index do
    selectable_column
    column :id
    column 'Type', sortable: 'lookup_type.name' do |caller|
      caller.lookup_type.name
    end
    column :value
    column :description
    column :rank
    actions defaults: true, dropdown: true
  end

  filter :lookup_type, label: 'Type'
  filter :value
  filter :description
  filter :rank

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
end
