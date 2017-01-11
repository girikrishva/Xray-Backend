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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :project_status_id, :start_date, :end_date, :booking_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :pipeline_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'business_units.name_asc_and_clients.name_asc_and_name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Project.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_projects_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = Project.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_projects_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      Project.restore(id)
    end
    redirect_to admin_projects_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_projects_path
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
    column I18n.t('label.invoiced_amount'), :invoiced_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.invoiced_amount, precision: 0, delimiter: ','
      end
    end
    column I18n.t('label.paid_amount'), :paid_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.paid_amount, precision: 0, delimiter: ','
      end
    end
    column I18n.t('label.unpaid_amount'), :unpaid_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.unpaid_amount, precision: 0, delimiter: ','
      end
    end
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_project_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item "Audit Trail", admin_projects_audits_path(project_id: resource.id)
        item I18n.t('actions.staffing_requirements'), admin_project_staffing_requirements_path(pipeline_id: resource.pipeline_id)
        item I18n.t('actions.assigned_resources'), admin_assigned_resources_path(project_id: resource.id)
        item I18n.t('actions.project_overheads'), admin_project_overheads_path(project_id: resource.id)
        item I18n.t('actions.delivery_milestones'), admin_delivery_milestones_path(project_id: resource.id)
        item I18n.t('actions.invoicing_milestones'), admin_invoicing_milestones_path(project_id: resource.id)
      end
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :client, collection: proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}
  filter :name, label: I18n.t('label.project')
  filter :start_date, label: I18n.t('label.start')
  filter :end_date, label: I18n.t('label.end')
  filter :booking_value, label: I18n.t('label.value')
  filter :project_type_code, label: I18n.t('label.type'), collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }
  filter :project_status, label: I18n.t('label.status')
  filter :sales_person, label: I18n.t('label.sales_by'), collection:
                          proc { AdminUser.ordered_lookup }
  filter :estimator, label: I18n.t('label.estimated_by'), collection:
                       proc { AdminUser.ordered_lookup }
  filter :engagement_manager, label: I18n.t('label.engagement_by'), collection:
                                proc { AdminUser.ordered_lookup }
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
        div :style => "text-align: left;" do
          number_with_precision element.booking_value, precision: 0, delimiter: ','
        end
      end
      row :project_type_code do
        r.project_type_code.name
      end
      row :project_status
      row I18n.t('label.sales_by'), :sales_person do
        r.sales_person.name
      end
      row I18n.t('label.estimated_by'), :estimator do
        r.estimator.name
      end
      row I18n.t('label.engagement_by'), :engagement_manager do
        r.engagement_manager.name
      end
      row I18n.t('label.delivery_by'), :delivery_manager do
        r.delivery_manager.name
      end
      row :pipeline do
        r.pipeline.name
      end
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      Project.includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
    end

    def create
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url and return if resource.valid?
      end
    end

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url and return if resource.valid?
      end
    end

    def restore
      Project.restore(params[:id])
      redirect_to admin_projects_path
    end

    def missed_delivery
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).missed_delivery(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def missed_invoicing
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).missed_invoicing(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def missed_payments
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).missed_payments(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def direct_resource_cost
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).direct_resource_cost(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def direct_overhead_cost
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).direct_overhead_cost(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def total_direct_cost
      project_id = params[:id]
      as_on = params[:as_on]
      result = Project.find(project_id).total_direct_cost(as_on)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def total_indirect_resource_cost_share
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).total_indirect_resource_cost_share(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def total_indirect_overhead_cost_share
      project_id = params[:id]
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = Project.find(project_id).total_indirect_overhead_cost_share(as_on, with_details)
      render json: '{"result": "' + result.to_json + '"}'
    end

    def total_indirect_cost_share
      project_id = params[:id]
      as_on = params[:as_on]
      result = Project.find(project_id).total_indirect_cost_share(as_on)
      render json: '{"result": "' + result.to_json + '"}'
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
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
      f.input :ip_address, as: :hidden
      f.input :updated_by, as: :hidden
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
