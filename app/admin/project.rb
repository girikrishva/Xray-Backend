ActiveAdmin.register Project do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: I18n.t('menu.projects'), parent: I18n.t('menu.operations'), priority: 10

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

  action_item only:  [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_projects_path
  end

  scope I18n.t('label.delivery_view'), :delivery_view, default: true do |projects|
    Project.all
  end

  scope I18n.t('label.sales_view'), :sales_view, default: false do |projects|
    Project.all
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column I18n.t('label.project'), :name
    column I18n.t('label.start'), :start_date
    column I18n.t('label.end'), :end_date
    column I18n.t('label.value'), :booking_value do |element|
      div :style => "text-align: right;" do
        number_with_precision element.booking_value, precision: 0, delimiter: ','
      end
    end
    column I18n.t('label.type'), :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column I18n.t('label.status'), :project_status, sortable: 'project_statuses.name' do |resource|
      resource.project_status.name
    end
    if params[:scope] == 'sales_view'
      column I18n.t('label.sales_by'), :sales_person, sortable: 'admin_users.name' do |resource|
        resource.sales_person.name
      end
      column I18n.t('label.estimated_by'), :estimator, sortable: 'admin_users.name' do |resource|
        resource.estimator.name
      end
    end
    if !params.has_key?('scope') || params[:scope] == 'delivery_view'
      column I18n.t('label.engagement_by'), :engagement_manager, sortable: 'admin_users.name' do |resource|
        resource.engagement_manager.name rescue nil
      end
      column I18n.t('label.delivery_by'), :delivery_manager, sortable: 'admin_users.name' do |resource|
        resource.delivery_manager.name rescue nil
      end
      column :comments
    end
    actions defaults: true, dropdown: true do |resource|
      item "Audit Trail", admin_projects_audits_path(project_id: resource.id)
      item I18n.t('actions.staffing_requirements'), admin_project_staffing_requirements_path(pipeline_id: resource.pipeline_id)
      item I18n.t('actions.assigned_resources'), admin_assigned_resources_path(project_id: resource.id)
      item I18n.t('actions.project_overheads'), admin_project_overheads_path(project_id: resource.id)
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :client, collection:
                    proc { Client.ordered_lookup }
  filter :name, label: I18n.t('label.project')
  filter :start_date, label: I18n.t('label.start')
  filter :end_date, label: I18n.t('label.end')
  filter :booking_value, label: I18n.t('label.value')
  filter :project_type_code, label: I18n.t('label.type'), collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }
  filter :project_status, label: I18n.t('label.status')
  filter :sales_person, label: I18n.t('label.sales_by'), collection:
                          proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'sales_view' }
  filter :estimator, label: I18n.t('label.estimated_by'), collection:
                       proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'sales_view' }
  filter :engagement_manager, label: I18n.t('label.engagement_by'), collection:
                                proc { AdminUser.ordered_lookup }, if: proc { !params.has_key?('scope') || params[:scope] == 'delivery_view' }
  filter :delivery_manager, label: I18n.t('label.delivery_by'), collection:
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
      row I18n.t('label.sales_by'), :sales_person
      row I18n.t('label.estimated_by'), :estimator
      row I18n.t('label.engagement_by'), :engagement_manager
      row I18n.t('label.delivery_by'), :delivery_manager
      row :pipeline
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
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
    if f.object.project_status_id.blank?
      f.object.project_status_id = ProjectStatus.where(name: I18n.t('label.new')).first.id
    end
    f.inputs do
      f.input :business_unit, required: true
      f.input :client, required: true, as: :select, collection:
                         Client.all.order('name asc').map { |a| [a.name, a.id] }, include_blank: true
      f.input :name
      f.input :start_date, required: true, label: I18n.t('label.start'), as: :datepicker
      f.input :end_date, required: true, label: I18n.t('label.end'), as: :datepicker
      f.input :booking_value, required: true, label: I18n.t('label.value')
      f.input :project_type_code, required: true
      f.input :project_status, required: true
      f.input :sales_person, required: true, label: I18n.t('label.sales_by'), as: :select, collection:
                               AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :estimator, required: true, label: I18n.t('label.estimated_by'), as: :select, collection:
                            AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :engagement_manager, required: true, label: I18n.t('label.engagement_by'), as: :select, collection:
                                     AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :delivery_manager, required: true, label: I18n.t('label.delivery_by'), as: :select, collection:
                                   AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
