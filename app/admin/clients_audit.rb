ActiveAdmin.register ClientsAudit do
  menu false

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    ClientsAudit.only_deleted.where('client_id = ?', params[:client_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_clients_audits_path(client_id: params[:client_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_clients_audits_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    client_id = ClientsAudit.without_deleted.find(ids.first).client_id
    ids.each do |id|
      object = ClientsAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_clients_audits_path(client_id: client_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    client_id = ClientsAudit.with_deleted.find(ids.first).client_id
    ids.each do |id|
      ClientsAudit.restore(id)
    end
    redirect_to admin_clients_audits_path(client_id: client_id)
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :name do
    selectable_column
    column :id
    column :business_unit
    column :contact_name
    column :contact_email
    column :contact_phone
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_clients_audit_path(resource.id)
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    before_filter only: :index do |resource|
      if !params.has_key?(:client_id)
        redirect_to admin_clients_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"client_id_eq" => params[:client_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_action
      ClientsAudit.includes [:business_unit, :client]
    end
  end

  filter :id
  filter :business_unit
  filter :contact_name
  filter :contact_email
  filter :contact_phone
  filter :comments
  filter :updated_at
  filter :updated_by
  filter :ip_address
end
