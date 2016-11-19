ActiveAdmin.register Pipeline do
  menu if: proc { is_menu_authorized? ["Manager"] }, label: 'Pipelines', parent: 'Operations', priority: 10

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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :sales_person_id, :estimator_id

  config.sort_order = 'business_units.name_asc_and_clients.name_asc_and_name_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_pipeline_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_pipelines_path
  end

# index do
  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column "Project", :name
    column "Start", :expected_start
    column "End", :expected_end
    column "Value", :expected_value do |element|
      div :style => "text-align: right;" do
        number_with_precision element.expected_value, precision: 0, delimiter: ','
      end
    end
    column "Type", :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column "Status", :pipeline_status, sortable: 'pipeline_statuses.name' do |resource|
      resource.pipeline_status.name
    end
    column :sales_person, sortable: 'admin_users.name' do |resource|
      resource.sales_person.name
    end
    column :estimator, sortable: 'admin_users.name' do |resource|
      resource.estimator.name
    end
    column :comments
    actions defaults: true, dropdown: true do |resource|
      item "Audit Trail", admin_pipelines_audits_path(pipeline_id: resource.id)
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name('Business Units') }
  filter :client, collection:
                    proc { Client.ordered_lookup }
  filter :name, label: 'Project'
  filter :expected_start, label: 'Start'
  filter :expected_end, label: 'End'
  filter :expected_value, label: 'Value'
  filter :project_type_code, label: 'Type', collection:
                               proc { Lookup.lookups_for_name('Project Code Types') }
  filter :pipeline_status, label: 'Status'
  filter :sales_person, collection:
                          proc { AdminUser.ordered_lookup }
  filter :estimator, collection:
                          proc { AdminUser.ordered_lookup }
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :business_unit do
        r.business_unit.name
      end
      row :client do
        r.client.name
      end
      row :name
      row :expected_start
      row :expected_end
      row :expected_value do |element|
        div :style => "text-align: right;" do
          number_with_precision element.expected_value, precision: 0, delimiter: ','
        end
      end
      row :project_type_code do
        r.project_type_code.name
      end
      row :pipeline_status
      row :sales_person
      row :estimator
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Executive"])
    end

    def scoped_collection
      Pipeline.includes [:business_unit, :client, :pipeline_status, :project_type_code, :sales_person, :estimator]
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

  form do |f|
    if f.object.pipeline_status_id.blank?
      f.object.pipeline_status_id = PipelineStatus.where(name: 'New').first.id
    end
    f.inputs do
      f.input :business_unit
      f.input :client, as: :select, collection:
                         Client.all.order('name asc').map { |a| [a.name, a.id] }, include_blank: true
      f.input :name
      f.input :expected_start, as: :datepicker
      f.input :expected_end, as: :datepicker
      f.input :expected_value
      f.input :project_type_code
      f.input :pipeline_status
      f.input :sales_person, as: :select, collection:
                               AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :estimator, as: :select, collection:
                               AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
