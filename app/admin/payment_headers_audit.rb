ActiveAdmin.register PaymentHeadersAudit do
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

  permit_params :client_id, :narrative, :payment_date, :header_amount, :payment_status_id, :comments, :payment_header_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'id_desc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    PaymentHeadersAudit.only_deleted.where('payment_header_id = ?', params[:payment_header_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_payment_headers_audits_path(payment_header_id: params[:payment_header_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_payment_headers_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    payment_header_id = PaymentHeadersAudit.without_deleted.find(ids.first).payment_header_id
    ids.each do |id|
      object = PaymentHeadersAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_payment_headers_audits_path(payment_header_id: payment_header_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    payment_header_id = PaymentHeadersAudit.with_deleted.find(ids.first).payment_header_id
    ids.each do |id|
      PaymentHeadersAudit.restore(id)
    end
    redirect_to admin_payment_headers_audits_path(payment_header_id: payment_header_id)
  end

  index as: :grouped_table, group_by_attribute: :payment_header_name do
    selectable_column
    column :id
    column :client, sortable: 'client.name' do |resource|
      resource.client.name
    end
    column :narrative
    column :payment_date
    column :payment_status, sortable: 'payment_statuses.name' do |resource|
      resource.payment_status.name
    end
    column :header_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.header_amount, precision: 0, delimiter: ','
      end
    end
    column :unreconciled_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.unreconciled_amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_payment_headers_audit_path(resource.id)
    end
  end

  filter :client, collection: proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}
  filter :narrative
  filter :payment_date
  filter :payment_status
  filter :header_amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :client do
        r.client.name
      end
      row :narrative
      row :payment_date
      row :payment_status do
        r.payment_status.name
      end
      row :header_amount
      row :unreconciled_amount
      row :comments
      row :audit_details
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:payment_header_id)
        redirect_to admin_payment_headers_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"payment_header_id_eq" => params[:invoice_header_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      PaymentHeadersAudit.includes [:client, :payment_status, :payment_header]
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
