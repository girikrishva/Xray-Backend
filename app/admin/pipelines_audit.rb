ActiveAdmin.register PipelinesAudit do
  menu false

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :pipeline_id, :sales_person_id, :estimator_id

  config.sort_order = 'id_desc'

  config.clear_action_items!

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    pipeline_id = PipelinesAudit.without_deleted.find(ids.first).pipeline_id
    ids.each do |id|
      PipelinesAudit.destroy(id)
    end
    redirect_to admin_pipelines_audits_path(pipeline_id: pipeline_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    pipeline_id = PipelinesAudit.with_deleted.find(ids.first).pipeline_id
    ids.each do |id|
      PipelinesAudit.restore(id)
    end
    redirect_to admin_pipelines_audits_path(pipeline_id: pipeline_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_pipelines_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  scope I18n.t('label.sales_view'), :sales_view, default: true do |pipelines|
    PipelinesAudit.all.order('id desc')
  end
  scope I18n.t('label.delivery_view'), :delivery_view, default: false do |pipelines|
    PipelinesAudit.all.order('id desc')
  end

  scope I18n.t('label.active'), default: false do |resources|
    PipelinesAudit.without_deleted.where('pipeline_id = ?', params[:pipeline_id]).order('id desc')
  end

  scope I18n.t('label.deleted'), default: false do |resources|
    PipelinesAudit.only_deleted.where('pipeline_id = ?', params[:pipeline_id]).order('id desc')
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
    if !params.has_key?('scope') || params[:scope] == 'sales_view'
      column I18n.t('label.sales_by'), :sales_person, sortable: 'admin_users.name' do |resource|
        resource.sales_person.name
      end
      column I18n.t('label.estimated_by'), :estimator, sortable: 'admin_users.name' do |resource|
        resource.estimator.name
      end
    end
    if params[:scope] == 'delivery_view'
      column I18n.t('label.engagement_by'), :engagement_manager, sortable: 'admin_users.name' do |resource|
        resource.engagement_manager.name rescue nil
      end
      column I18n.t('label.delivery_by'), :delivery_manager, sortable: 'admin_users.name' do |resource|
        resource.delivery_manager.name rescue nil
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_pipelines_audit_path(resource.id)
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :client, collection:
                    proc { Client.ordered_lookup }
  filter :name, label: I18n.t('label.project')
  filter :expected_start, label: I18n.t('label.start')
  filter :expected_end, label: I18n.t('label.end')
  filter :expected_value, label: I18n.t('label.value')
  filter :project_type_code, label: I18n.t('label.type'), collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }
  filter :pipeline_status, label: I18n.t('label.status')
  filter :sales_person, label: I18n.t('label.sales_by'), collection:
                          proc { AdminUser.ordered_lookup }, if: proc { !params.has_key?('scope') || params[:scope] == 'sales_view' }
  filter :estimator, label: I18n.t('label.estimated_by'), collection:
                       proc { AdminUser.ordered_lookup }, if: proc { !params.has_key?('scope') || params[:scope] == 'sales_view' }
  filter :engagement_manager, label: I18n.t('label.engagement_by'), collection:
                                proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'delivery_view' }
  filter :delivery_manager, label: I18n.t('label.delivery_by'), collection:
                              proc { AdminUser.ordered_lookup }, if: proc { params[:scope] == 'delivery_view' }
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
      row I18n.t('label.sales_by'), :sales_person
      row I18n.t('label.estimated_by'), :estimator
      row I18n.t('label.engagement_by'), :engagement_manager
      row I18n.t('label.delivery_by'), :delivery_manager
      row :comments
      row :audit_details
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
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
      PipelinesAudit.includes [:business_unit, :client, :pipeline_status, :project_type_code, :pipeline, :sales_person, :estimator, :engagement_manager, :delivery_manager]
    end
  end
end
