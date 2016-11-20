ActiveAdmin.register Project do
  menu if: proc { is_menu_authorized? ["Manager"] }, label: 'Projects', parent: 'Operations', priority: 10

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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :project_status_id, :start_date, :end_date, :booking_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :pipeline_id

  config.sort_order = 'business_units.name_asc_and_clients.name_asc_and_name_asc'

  config.clear_action_items!

  action_item only: :show do |resource|
    link_to "Back", admin_projects_path
  end

  scope :delivery_view, default: true do |pipelines|
    Project.all
  end

  scope :sales_view, default: false do |pipelines|
    Project.all
  end

# index do
  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column "Project", :name
    column "Start", :start_date
    column "End", :end_date
    column "Value", :booking_value do |element|
      div :style => "text-align: right;" do
        number_with_precision element.booking_value, precision: 0, delimiter: ','
      end
    end
    column "Type", :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column "Status", :project_status, sortable: 'project_statuses.name' do |resource|
      resource.project_status.name
    end
    column :sales_person, sortable: 'admin_users.name' do |resource|
      resource.sales_person.name
    end
    if params[:scope] == 'sales_view'
      column :estimator, sortable: 'admin_users.name' do |resource|
        resource.estimator.name
      end
      column :engagement_manager, sortable: 'admin_users.name' do |resource|
        resource.engagement_manager.name rescue nil
      end
    end
    if !params.has_key?('scope') || params[:scope] == 'delivery_view'
      column :delivery_manager, sortable: 'admin_users.name' do |resource|
        resource.delivery_manager.name rescue nil
      end
      column :comments
      actions defaults: true, dropdown: true do |resource|
        # item "Audit Trail", admin_projects_audits_path(project_id: resource.id)
      end
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name('Business Units') }
  filter :client, collection:
                    proc { Client.ordered_lookup }
  filter :name, label: 'Project'
  filter :start_date, label: 'Start'
  filter :end_date, label: 'End'
  filter :booking_value, label: 'Value'
  filter :project_type_code, label: 'Type', collection:
                               proc { Lookup.lookups_for_name('Project Code Types') }
  filter :project_status, label: 'Status'
  filter :sales_person, collection:
                          proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'sales_view' }
  filter :estimator, collection:
                       proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'sales_view' }
  filter :engagement_manager, collection:
                                proc { AdminUser.ordered_lookup }, if: proc { !params.has_key?('scope') || params[:scope] == 'delivery_view' }
  filter :delivery_manager, collection:
                              proc { AdminUser.ordered_lookup }, if: proc { !params.has_key?('scope') || params[:scope] == 'delivery_view' }
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
      row :start_date
      row :end_date
      row :booking_value do |element|
        div :style => "text-align: right;" do
          number_with_precision element.booking_value, precision: 0, delimiter: ','
        end
      end
      row :project_type_code do
        r.project_type_code.name
      end
      row :project_status
      row :sales_person
      row :estimator
      row :engagement_manager
      row :delivery_manager
      row :pipeline
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Executive"])
    end

    def scoped_collection
      Project.includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
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
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :booking_value
      f.input :project_type_code
      f.input :project_status
      f.input :sales_person, as: :select, collection:
                               AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :estimator, as: :select, collection:
                            AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :engagement_manager, as: :select, collection:
                                     AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :delivery_manager, as: :select, collection:
                                   AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
