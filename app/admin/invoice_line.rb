ActiveAdmin.register InvoiceLine do
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

  permit_params :invoice_header_id, :project_id, :invoicing_milestone_id, :invoice_adder_type_id, :narrative, :line_amount, :comments, :updated_at, :updated_by, :ip_address

  config.sort_order = 'projects.name_asc_and_narrative_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    InvoiceLine.only_deleted.where('invoice_header_id = ?', params[:invoice_header_id]).order('narrative asc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_invoice_lines_path(invoice_header_id: params[:invoice_header_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_invoice_line_path(invoice_header_id: session[:invoice_header_id]) if session.has_key?(:invoice_header_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_invoice_lines_path(invoice_header_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_invoice_lines_path(invoice_header_id: session[:invoice_header_id]) if session.has_key?(:invoice_header_id)
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = InvoiceLine.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_invoice_lines_path(invoice_header_id: session[:invoice_header_id])
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      InvoiceLine.restore(id)
    end
    redirect_to admin_invoice_lines_path(invoice_header_id: session[:invoice_header_id])
  end

  index as: :grouped_table, group_by_attribute: :invoice_header_name do
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
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_invoice_line_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item "Audit Trail", admin_invoice_lines_audits_path(invoice_line_id: resource.id)
      end
    end
  end

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
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if params.has_key?(:invoice_header_id)
        session[:invoice_header_id] = params[:invoice_header_id]
      else
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
      InvoiceLine.includes [:invoice_header, :project, :invoicing_milestone, :invoice_adder_type]
    end

    def create
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end

    def invoicing_milestone
      invoicing_milestone_id = params[:invoicing_milestone_id]
      invoicing_milestone = InvoicingMilestone.find(invoicing_milestone_id)
      render json: '{"invoicing_milestone": ' + invoicing_milestone.to_json + '}'
    end

    def invoicing_milestone_uninvoiced
      invoicing_milestone_id = params[:invoicing_milestone_id]
      invoicing_milestone = InvoicingMilestone.find(invoicing_milestone_id)
      render json: '{"invoicing_milestone_uninvoiced": ' + invoicing_milestone.uninvoiced.to_json + '}'
    end

    def invoice_adder_type
      invoice_adder_type_id = params[:invoice_adder_type_id]
      invoice_adder_type = InvoiceAdderType.find(invoice_adder_type_id)
      render json: '{"invoice_adder_type": ' + invoice_adder_type.to_json + '}'
    end

    def invoice_line_narrative
      invoice_line_id = params[:invoice_line_id]
      invoice_line = InvoiceLine.find(invoice_line_id)
      render json: '{"invoice_line_narrative": ' + invoice_line.narrative.to_json + '}'
    end

    def unpaid_amount
      invoice_line_id = params[:invoice_line_id]
      invoice_line = InvoiceLine.find(invoice_line_id)
      render json: '{"unpaid_amount": ' + invoice_line.unpaid_amount.to_json + '}'
    end

    def invoice_lines_for_header
      invoice_header_id = params[:invoice_header_id]
      results = InvoiceLine.where(invoice_header_id: invoice_header_id)
      invoice_lines = []
      results.each do |result|
        invoice_line = {}
        invoice_line[:id] = result.id
        invoice_line[:narrative] = result.narrative
        invoice_line[:line_amount] = result.line_amount
        invoice_line[:unpaid_amount] = result.unpaid_amount
        invoice_lines << invoice_line
      end
      render json: '{"invoice_lines": ' + invoice_lines.to_json + '}'
    end

    def destroy
      super do |format|
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end

    def restore
      InvoiceLine.restore(params[:id])
      redirect_to admin_invoice_lines_path(invoice_header_id: session[:invoice_header_id])
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
    f.object.invoice_header_id = session[:invoice_header_id]
    f.inputs do
      f.input :invoice_header, label: I18n.t('label.invoice_header'), as: :select, collection: InvoiceHeader.where(id: session[:invoice_header_id]).map { |a| [a.invoice_header_name, a.id] }, input_html: {disabled: true}, required: true
      f.input :invoice_header_id, as: :hidden, required: true
      if f.object.new_record?
        f.input :project, label: I18n.t('label.project'), as: :select, collection: Project.where(client_id: InvoiceHeader.where(id: session[:invoice_header_id]).first.client_id).map { |a| [a.name, a.id] }, required: true
      else
        f.input :project, label: I18n.t('label.project'), as: :select, collection: Project.where(client_id: InvoiceHeader.where(id: session[:invoice_header_id]).first.client_id).map { |a| [a.name, a.id] }, input_html: {disabled: true}, required: true
        f.input :project_id, as: :hidden
      end
      f.input :invoicing_milestone, label: I18n.t('label.invoicing_milestone'), input_html: {disabled: true}
      f.input :invoice_adder_type, label: I18n.t('label.invoice_adder_type'), collection: InvoiceAdderType.all.map { |a| [a.invoice_adder_type_name, a.id] }, input_html: {disabled: true}
      f.input :narrative, label: I18n.t('label.narrative'), required: true
      f.input :line_amount, label: I18n.t('label.line_amount'), required: true
      f.input :comments, label: I18n.t('label.comments')
      f.input :ip_address, as: :hidden
      f.input :updated_by, as: :hidden
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
