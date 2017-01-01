ActiveAdmin.register Pipeline do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: I18n.t('menu.pipelines'), parent: I18n.t('menu.operations'), priority: 20

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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'business_units.name_asc_and_clients.name_asc_and_name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Pipeline.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_pipelines_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_pipeline_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_pipelines_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = Pipeline.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_pipelines_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      Pipeline.restore(id)
    end
    redirect_to admin_pipelines_path
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column I18n.t('label.project'), :name
    column I18n.t('label.start'), :expected_start
    column I18n.t('label.end'), :expected_end
    column I18n.t('label.value'), :expected_value do |element|
      div :style => "text-align: right;" do
        number_with_precision element.expected_value, precision: 0, delimiter: ','
      end
    end
    column I18n.t('label.type'), :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column I18n.t('label.status'), :pipeline_status, sortable: 'pipeline_statuses.name' do |resource|
      resource.pipeline_status.name
    end
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_pipeline_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.audit_trail'), admin_pipelines_audits_path(pipeline_id: resource.id)
        item I18n.t('actions.staffing_requirements'), admin_staffing_requirements_path(pipeline_id: resource.id)
        item I18n.t('actions.convert_pipeline'), admin_api_convert_pipeline_path(pipeline_id: resource.id), method: :post
      end
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :client, collection:  proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}
  filter :name, label: I18n.t('label.project')
  filter :expected_start, label: I18n.t('label.start')
  filter :expected_end, label: I18n.t('label.end')
  filter :expected_value, label: I18n.t('label.value')
  filter :project_type_code, label: 'Type', collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }
  filter :pipeline_status, label: I18n.t('label.status')
  filter :sales_person, label: I18n.t('label.sales_by'), collection:
                          proc { AdminUser.ordered_lookup }
  filter :estimator, label: I18n.t('label.estimated_by'), collection:
                       proc { AdminUser.ordered_lookup }
  filter :engagement_manager, label: I18n.t('label.engagement_by'), collection:
                                proc { AdminUser.ordered_lookup }
  filter :delivery_manager, label: I18n.t('label.delivery_by'), collection:
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
        div :style => "text-align: left;" do
          number_with_precision element.expected_value, precision: 0, delimiter: ','
        end
      end
      row :project_type_code do
        r.project_type_code.name
      end
      row :pipeline_status
      row I18n.t('label.sales_by'), :sales_person
      row I18n.t('label.estimated_by'), :estimator
      row I18n.t('label.engagement_by'), :engagement_manager
      row I18n.t('label.delivery_by'), :delivery_manager
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      Pipeline.includes [:business_unit, :client, :pipeline_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager]
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

    def convert_pipeline
      if params.has_key?(:pipeline_id)
        pipeline = Pipeline.find(params[:pipeline_id])
        pipeline.convert_pipeline(pipeline)
        if !pipeline.errors.empty?
          flash[:error] = pipeline.errors.full_messages.to_sentence
        end
        redirect_to collection_url
      end
    end

    def restore
      Pipeline.restore(params[:id])
      redirect_to admin_pipelines_path
    end

    def clients_for_business_unit
      business_unit_id = params[:business_unit_id]
      resources = Client.where('business_unit_id = ?', business_unit_id).order(:name)
      render json: '{"resources": ' + resources.to_json.to_json + '}'
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
    if f.object.pipeline_status_id.blank?
      f.object.pipeline_status_id = PipelineStatus.where(name: I18n.t('label.new')).first.id
    end
    f.inputs do
      if f.object.new_record?
        f.input :business_unit, required: true
      else
        f.input :business_unit, required: true, input_html: {disabled: true}
        f.input :business_unit_id, as: :hidden
      end
      f.input :client, required: true, as: :select, collection:
                         Client.all.order('name asc').map { |a| [a.name, a.id] }, include_blank: true, input_html: {disabled: true}
      f.input :name
      f.input :expected_start, as: :datepicker
      f.input :expected_end, as: :datepicker
      f.input :expected_value
      f.input :project_type_code, required: true
      if f.object.new_record?
        f.input :pipeline_status_id, as: :hidden
      else
        f.input :pipeline_status, required: true
      end
      f.input :sales_person, required: true, label: I18n.t('label.sales_by'), as: :select, collection:
                               AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :estimator, required: true, label: I18n.t('label.estimated_by'), as: :select, collection:
                            AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :engagement_manager, label: I18n.t('label.engagement_by'), as: :select, collection:
                                     AdminUser.ordered_lookup.map { |a| [a.name, a.id] }, include_blank: true
      f.input :delivery_manager, label: I18n.t('label.delivery_by'), as: :select, collection:
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
