ActiveAdmin.register InvoiceHeader do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: I18n.t('menu.invoices'), parent: I18n.t('menu.operations'), priority: 30

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

  permit_params :client_id, :narrative, :invoice_date, :invoice_term_id, :invoice_status_id, :comments, :due_date, :header_amount, :updated_by, :ip_address

  config.sort_order = 'invoice_date_desc_and_narrative_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    InvoiceHeader.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_invoice_headers_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_invoice_header_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_invoice_headers_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      InvoiceHeader.destroy(id)
    end
    redirect_to admin_invoice_headers_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      InvoiceHeader.restore(id)
    end
    redirect_to admin_invoice_headers_path
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
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
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_invoice_header_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item "Audit Trail", admin_invoice_headers_audits_path(invoice_header_id: resource.id)
        item I18n.t('actions.invoice_lines'), admin_invoice_lines_path(invoice_header_id: resource.id)
      end
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
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      InvoiceHeader.includes [:client, :invoice_term, :invoice_status]
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

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url and return if resource.valid?
      end
    end

    def restore
      InvoiceHeader.restore(params[:id])
      redirect_to admin_invoice_headers_path
    end

    def collection_milestones
      as_on = params[:as_on]
      due_status = params[:due_status]
      completion_status = params[:completion_status]
      result = InvoiceHeader.invoice_headers(as_on, due_status, completion_status)
      render json: result
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
    if f.object.invoice_term_id.blank?
      f.object.invoice_term_id = InvoiceTerm.where(name: I18n.t('label.default_invoice_term')).first.id
    end
    if f.object.invoice_status_id.blank?
      f.object.invoice_status_id = InvoiceStatus.where(name: I18n.t('label.new')).first.id
    end
    if f.object.invoice_date.blank?
      f.object.invoice_date = Date.today
    end
    if f.object.new_record?
      f.object.header_amount = 0
    end
    f.inputs do
      f.input :client, required: true, as: :select, collection:proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}, include_blank: true
      f.input :narrative
      f.input :invoice_date, required: true, label: I18n.t('label.invoice_date'), as: :datepicker
      f.input :invoice_term
      f.input :invoice_status
      f.input :header_amount, as: :hidden
      f.input :comments
      f.input :ip_address, as: :hidden
      f.input :updated_by, as: :hidden
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
