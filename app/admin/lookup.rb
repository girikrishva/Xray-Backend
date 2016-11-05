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

  config.sort_order = 'lookup_types.name_asc_and_rank_asc'

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

  controller do
    before_filter only: :index do

      # if filter button wasn't clicked
      if params[:commit].blank? && params[:q].blank?

        # use default parameters
        extra_params = {"q" => {"lookup_type_id_eq" => params[:lookup_type_id]}}

        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_collection
      Lookup.includes [:lookup_type]
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

  filter :lookup_type, label: 'Type'
  filter :value
  filter :description
  filter :rank
end
