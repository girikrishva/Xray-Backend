ActiveAdmin.register Lookup do

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

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_lookup_path(lookup_type: params[:lookup_type]) if params.has_key?(:lookup_type)
  end

  action_item only: :index do |resource|
    link_to "Back", admin_lookup_types_path(lookup_type: nil)
  end

  index do
    selectable_column
    column :id
    # column :lookup_type
    column 'Type', sortable: 'lookup_type.name' do |caller|
      caller.lookup_type.name
    end
    column :value
    column :description
    column :rank
    column :comments
    actions defaults: true, dropdown: true
  end

  controller do
    before_filter only: :index do |resource|
      # if filter button wasn't clicked
      if params[:commit].blank? && params[:q].blank?
        # use default parameters

        extra_params = {"q" => {"lookup_type_id_eq" => params[:lookup_type]}}

        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_collection
      Lookup.includes [:lookup_type]
    end

    def create
      super do |format|
        redirect_to collection_url(lookup_type: resource.lookup_type_id) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url(lookup_type: resource.lookup_type_id) and return if resource.valid?
      end
    end
  end

  filter :lookup_type, label: 'Type'
  filter :value
  filter :description
  filter :rank
  filter :comments

  form do |f|
    if params.has_key?(:lookup_type)
      f.object.lookup_type_id = params[:lookup_type]
    end
    f.inputs do
      f.input :lookup_type, input_html: { disabled: :true }
      f.input :value
      f.input :description
      f.input :rank
      f.input :comments
    end
    f.actions
  end
end
