ActiveAdmin.register Lookup do
  menu false
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

  permit_params :name, :description, :rank, :comments, :lookup_type_id

  config.sort_order = 'rank_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_lookup_path(lookup_type_id: session[:lookup_type_id]) if session.has_key?(:lookup_type_id)
  end

  action_item only: :index do |resource|
    link_to "Back", admin_lookup_types_path(lookup_type_id: nil)
  end

  action_item only: :show do |resource|
    link_to "Back", admin_lookups_path(lookup_type_id: session[:lookup_type_id]) if session.has_key?(:lookup_type_id)
  end

  batch_action :destroy do |ids|
    ids.each do |id|
      Lookup.delete(id)
    end
    redirect_to collection_url(lookup_type_id: session[:lookup_type_id])
  end

  index do
    selectable_column
    column :id
    column 'Type', :lookup_type do |caller|
      caller.lookup_type.name
    end
    column :name
    column :description
    column :rank
    column :comments
    actions defaults: true, dropdown: true
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Director"])
    end

    before_filter only: :index do |resource|
      if params.has_key?(:lookup_type_id)
        session[:lookup_type_id] = params[:lookup_type_id]
      else
        redirect_to admin_lookup_types_path
      end
      # if filter button wasn't clicked
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"lookup_type_id_eq" => session[:lookup_type_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_collection
      resource_class.includes(:lookup_type)
    end

    def create
      super do |format|
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end
  end

  filter :name
  filter :description
  filter :rank
  filter :comments

  form do |f|
    if session.has_key?(:lookup_type_id)
      f.object.lookup_type_id = session[:lookup_type_id]
      if f.object.rank.blank?
        f.object.rank = Lookup.max_rank_for_lookup_type(session[:lookup_type_id])
      end
    end
    f.inputs do
      f.input :lookup_type, label: "Type", input_html: {disabled: :true}
      f.input :lookup_type_id, as: :hidden
      f.input :name
      f.input :description
      f.input :rank
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
