ActiveAdmin.register PipelinesAudit do
  menu false

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :pipeline_id, :sales_person_id, :estimator_id

  config.sort_order = 'id_desc'

  config.clear_action_items!

  action_item only: :index do |resource|
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
    column :created_at
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
  filter :sales_person
  filter :estimator
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Manager"])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:pipeline_id)
        redirect_to admin_pipelines_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"pipeline_id_eq" => params[:pipeline_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_collection
      PipelinesAudit.includes [:business_unit, :client, :pipeline_status, :project_type_code, :pipeline, :sales_person, :estimator]
    end
  end
end