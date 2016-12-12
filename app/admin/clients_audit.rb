ActiveAdmin.register ClientsAudit do
  menu false

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_clients_audits_path
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :name
    column :contact_name
    column :contact_email
    column :contact_phone
    column :comments
    column :updated_at
    column :updated_by
    column :ip_address
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:client_id)
        redirect_to admin_clients_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"client_id" => params[:client_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_action
      ClientsAudit.includes [:business_unit, :client]
    end
  end

  filter :name
  filter :contact_name
  filter :contact_email
  filter :contact_phone
  filter :comments
  filter :updated_at
  filter :updated_by
  filter :ip_address
end
