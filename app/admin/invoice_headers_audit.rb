ActiveAdmin.register InvoiceHeadersAudit do
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

  permit_params :narrative, :invoice_date, :due_date, :header_amount, :comments, :created_at, :client_id, :invoice_status_id, :invoice_term_id, :invoice_header_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'id_desc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    InvoiceHeadersAudit.only_deleted.where('invoice_header_id = ?', params[:invoice_header_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_invoice_headers_audits_path(invoice_header_id: params[:invoice_header_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_invoice_headers_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    invoice_header_id = InvoiceHeadersAudit.without_deleted.find(ids.first).invoice_header_id
    ids.each do |id|
      object = InvoiceHeadersAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_invoice_headers_audits_path(invoice_header_id: invoice_header_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    invoice_header_id = InvoiceHeadersAudit.with_deleted.find(ids.first).invoice_header_id
    ids.each do |id|
      InvoiceHeadersAudit.restore(id)
    end
    redirect_to admin_invoice_headers_audits_path(invoice_header_id: invoice_header_id)
  end

  index as: :grouped_table, group_by_attribute: :invoice_header_name do
    selectable_column
    column :id
    column :client, sortable: 'client.name' do |resource|
      resource.client.name
    end
    column :narrative
    column :invoice_date
    column :invoice_term, sortable: 'invoice_terms.name' do |resource|
      resource.invoice_term.name
    end
    column :invoice_status, sortable: 'invoice_statuses.name' do |resource|
      resource.invoice_status.name
    end
    column :due_date
    column :header_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.header_amount, precision: 0, delimiter: ','
      end
    end
    column :unpaid_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.unpaid_amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_invoice_headers_audit_path(resource.id)
    end
  end

  filter :client, collection: proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}
  filter :narrative
  filter :invoice_date
  filter :invoice_term
  filter :invoice_status
  filter :due_date
  filter :header_amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :client do
        r.client.name
      end
      row :narrative
      row :invoice_date
      row :invoice_term do
        r.invoice_term.name
      end
      row :invoice_status do
        r.invoice_status.name
      end
      row :due_date
      row :header_amount
      row :unpaid_amount
      row :comments
      row :audit_details
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:invoice_header_id)
        redirect_to admin_invoice_headers_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"invoice_header_id_eq" => params[:invoice_header_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      InvoiceHeadersAudit.includes [:client, :invoice_term, :invoice_status, :invoice_header]
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
