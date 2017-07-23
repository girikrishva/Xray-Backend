ActiveAdmin.register InvoiceLinesAudit do
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

  permit_params :invoice_header_id, :project_id, :invoicing_milestone_id, :invoice_adder_type_id, :narrative, :line_amount, :comments, :invoice_line_id, :updated_at, :updated_by, :ip_address

  config.sort_order = 'id_desc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    InvoiceLinesAudit.only_deleted.where('invoice_line_id = ?', params[:invoice_line_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_invoice_lines_audits_path(invoice_header_id: params[:invoice_header_id], invoice_line_id: params[:invoice_line_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_invoice_lines_path(invoice_header_id: InvoiceLine.find(params[:invoice_line_id]).invoice_header_id)
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    invoice_line_id = InvoiceLinesAudit.without_deleted.find(ids.first).invoice_line_id
    ids.each do |id|
      object = InvoiceLinesAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_invoice_lines_audits_path(invoice_line_id: invoice_line_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    invoice_line_id = InvoiceLinesAudit.with_deleted.find(ids.first).invoice_line_id
    ids.each do |id|
      InvoiceLinesAudit.restore(id)
    end
    redirect_to admin_invoice_lines_audits_path(invoice_line_id: invoice_line_id)
  end

  index as: :grouped_table, group_by_attribute: :invoice_line_name do
    selectable_column
    column :id
    column :project do |resource|
      resource.project.name
    end
    column :invoicing_milestone do |resource|
      resource.invoicing_milestone.name rescue nil
    end
    column :invoicing_milestone_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.invoicing_milestone.amount, precision: 0, delimiter: ',' rescue nil
      end
    end
    column :uninvoiced do |element|
      div :style => "text-align: right;" do
        number_with_precision element.invoicing_milestone.uninvoiced, precision: 0, delimiter: ',' rescue nil
      end
    end
    column :invoice_adder_type do |resource|
      resource.invoice_adder_type.name rescue nil
    end
    column :narrative
    column :line_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.line_amount, precision: 0, delimiter: ','
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
      item I18n.t('actions.view'), admin_invoice_lines_audit_path(resource.id)
    end
  end

  filter :id
  filter :project
  filter :invoicing_milestone
  filter :invoice_adder_type
  filter :narrative
  filter :line_amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :invoice_header do
        r.invoice_header.invoice_header_name
      end
      row :project do
        r.project.name
      end
      row :invoicing_milestone do
        r.invoicing_milestone.invoicing_milestone_name rescue nil
      end
      row :invoicing_milestone_amount do
        r.invoicing_milestone.amount rescue nil
      end
      row :uninvoiced do
        r.invoicing_milestone.uninvoiced rescue nil
      end
      row :invoice_adder_type do
        r.invoice_adder_type.invoice_adder_type_name rescue nil
      end
      row :narrative
      row :line_amount
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
      if !params.has_key?(:invoice_line_id)
        redirect_to admin_invoice_lines_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"invoice_line_id_eq" => params[:invoice_line_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      InvoiceLinesAudit.includes [:invoice_header, :project, :invoicing_milestone, :invoice_adder_type, :invoice_line]
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
