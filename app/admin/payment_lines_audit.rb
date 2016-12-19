ActiveAdmin.register PaymentLinesAudit do
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

  permit_params :payment_header_id, :invoice_line_id, :narrative, :line_amount, :comments, :invoice_header_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'id_desc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    PaymentLinesAudit.only_deleted.where('payment_line_id = ?', params[:payment_line_id]).order('id desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_payment_lines_audits_path(payment_header_id: params[:payment_header_id], payment_line_id: params[:payment_line_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_payment_lines_path(payment_header_id: PaymentLine.find(params[:payment_line_id]).payment_header_id)
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    payment_line_id = PaymentLinesAudit.without_deleted.find(ids.first).payment_line_id
    ids.each do |id|
      PaymentLinesAudit.destroy(id)
    end
    redirect_to admin_payment_lines_audits_path(payment_line_id: payment_line_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    payment_line_id = PaymentLinesAudit.with_deleted.find(ids.first).payment_line_id
    ids.each do |id|
      PaymentLinesAudit.restore(id)
    end
    redirect_to admin_payment_lines_audits_path(payment_line_id: payment_line_id)
  end

  index as: :grouped_table, group_by_attribute: :payment_line_name do
    selectable_column
    column :id
    column :invoice_header do |resource|
      resource.invoice_header.invoice_header_name
    end
    column :invoice_line do |resource|
      resource.invoice_line.invoice_line_name
    end
    column :narrative
    column :line_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.line_amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_payment_lines_audit_path(resource.id)
    end
  end

  filter :invoice_header
  filter :invoice_line
  filter :narrative
  filter :line_amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :invoice_header do
        r.invoice_header.invoice_header_name
      end
      row :invoice_line do
        r.invoice_line.invoice_line_name
      end
      row :narrative
      row :line_amount
      row :comments
      row :audit_details
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:payment_line_id)
        redirect_to admin_payment_lines_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"payment_line_id_eq" => params[:payment_line_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      PaymentLinesAudit.includes [:payment_header, :invoice_line, :payment_line, :invoice_header]
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
