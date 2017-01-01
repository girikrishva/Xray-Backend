ActiveAdmin.register ProjectsAudit do
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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :project_status_id, :start_date, :end_date, :booking_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :pipeline_id, :project_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'id_desc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    ProjectsAudit.only_deleted.where('project_id = ?', params[:project_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_projects_audits_path(project_id: params[:project_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_projects_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    project_id = ProjectsAudit.without_deleted.find(ids.first).project_id
    ids.each do |id|
      object = ProjectsAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_projects_audits_path(project_id: project_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    project_id = ProjectsAudit.with_deleted.find(ids.first).project_id
    ids.each do |id|
      ProjectsAudit.restore(id)
    end
    redirect_to admin_projects_audits_path(project_id: project_id)
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
    column I18n.t('label.sales_by'), :sales_person, sortable: 'admin_users.name' do |resource|
      resource.sales_person.name
    end
    column I18n.t('label.estimated_by'), :estimator, sortable: 'admin_users.name' do |resource|
      resource.estimator.name
    end
    column I18n.t('label.engagement_by'), :engagement_manager, sortable: 'admin_users.name' do |resource|
      resource.engagement_manager.name rescue nil
    end
    column I18n.t('label.delivery_by'), :delivery_manager, sortable: 'admin_users.name' do |resource|
      resource.delivery_manager.name rescue nil
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_projects_audit_path(resource.id)
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
                              proc { AdminUser.ordered_lookup }
  filter :comments
  filter :updated_at
  filter :updated_by
  filter :ip_address

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
      row I18n.t('label.sales_by'), :sales_person
      row I18n.t('label.estimated_by'), :estimator
      row I18n.t('label.engagement_by'), :engagement_manager
      row I18n.t('label.delivery_by'), :delivery_manager
      row :pipeline
      row :updated_at
      row :updated_by
      row :ip_address
      row :comments
      row :audit_details
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:project_id)
        redirect_to admin_projects_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"project_id_eq" => params[:project_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      ProjectsAudit.includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline, :project]
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
end
