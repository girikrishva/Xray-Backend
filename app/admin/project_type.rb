ActiveAdmin.register ProjectType do
  menu if: proc { is_menu_authorized? ["Executive"] }, label: 'Project Types', parent: 'Setup', priority: 40

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

  permit_params :business_unit_id, :project_type_code_id, :description, :billed, :comments

  config.sort_order = 'business_units.name_asc_and_project_type_codes.name_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_project_type_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_project_types_path
  end

  index do
    selectable_column
    column :id
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column :description
    column :billed
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name('Business Units') }
  filter :project_type_code, collection:
                           proc { Lookup.lookups_for_name('Project Types') }
  filter :description
  filter :billed
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Executive"])
    end

    def scoped_collection
      ProjectType.includes  [:project_type_code, :business_unit]
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

    def description_for_lookup
      lookup_id = params[:lookup_id]
      description = Lookup.description_for_lookup(lookup_id)
      render json: '{"description": "' + description + '"}'
    end
  end

  form do |f|
    if f.object.billed.blank?
      f.object.billed = true
    end
    f.inputs do
      if f.object.business_unit_id.blank?
        f.input :business_unit, as: :select, collection:
                                  Lookup.lookups_for_name('Business Units')
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.project_type_code_id.blank?
        f.input :project_type_code, as: :select, collection:
                                  Lookup.lookups_for_name('Project Types')
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :project_type_code, input_html: {disabled: :true}
        f.input :project_type_code_id, as: :hidden
      end
      f.input :description
      f.input :billed
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
