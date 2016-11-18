ActiveAdmin.register PipelinesAudit do
  menu false

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :pipeline_id

  config.sort_order = 'business_units.name_asc_and_clients.name_asc_and_name_asc'

  config.clear_action_items!

  # action_item only: :index do |resource|
  #   link_to "New", new_admin_pipeline_path
  # end

  action_item only: :index do |resource|
    link_to "Back", admin_pipelines_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_pipelines_path
  end

  index do
    # index as: :grouped_table, group_by_attribute: :name do
    selectable_column
    column :id
    column :business_unit
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
      row :comments
    end
  end

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
      PipelinesAudit.includes [:business_unit, :client, :pipeline_status, :project_type_code, :pipeline]
    end

    # def create
    #   super do |format|
    #     redirect_to collection_url and return if resource.valid?
    #   end
    # end
    #
    # def update
    #   super do |format|
    #     redirect_to collection_url and return if resource.valid?
    #   end
    # end
  end

  # form do |f|
  #   f.inputs do
  #     f.input :business_unit
  #     f.input :client
  #     f.input :name
  #     f.input :expected_start, as: :datepicker
  #     f.input :expected_end, as: :datepicker
  #     f.input :expected_value
  #     f.input :project_type_code
  #     f.input :pipeline_status
  #     f.input :comments
  #   end
  #   f.actions do
  #     f.action(:submit, label: 'Save')
  #     f.cancel_link
  #   end
  # end
end
