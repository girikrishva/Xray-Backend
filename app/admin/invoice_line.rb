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

  permit_params :invoice_header_id, :project_id, :invoicing_milestone_id, :invoice_adder_type_id, :narrative, :line_amount, :comments

  config.sort_order = 'projects.name_asc_and_narrative_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_invoice_line_path(invoice_header_id: session[:invoice_header_id]) if session.has_key?(:invoice_header_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_invoice_lines_path(invoice_header_id: nil)
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_invoice_lines_path(invoice_header_id: session[:invoice_header_id]) if session.has_key?(:invoice_header_id)
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
    column :invoice_adder_type do |resource|
      resource.invoice_adder_type.name rescue nil
    end
    column :narrative
    column :line_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.line_amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    actions defaults: true, dropdown: true do |resource|
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
        r.invoicing_milestone.name rescue nil
      end
      row :invoice_adder_type do
        r.invoice_adder_type.name rescue nil
      end
      row :narrative
      row :line_amount
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


    def scoped_collection
      InvoiceLine.includes [:invoice_header, :project, :invoicing_milestone, :invoice_adder_type]
    end

    def create
      super do |format|
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url(invoice_header_id: session[:invoice_header_id]) and return if resource.valid?
      end
    end
  end

  form do |f|
    f.object.invoice_header_id = session[:invoice_header_id]
    f.inputs do
      f.input :invoice_header, label: I18n.t('label.invoice_header'), as: :select, collection: InvoiceHeader.where(id: session[:invoice_header_id]).map { |a| [a.invoice_header_name, a.id] }, input_html: {disabled: true}, required: true
      f.input :invoice_header_id, as: :hidden, required: true
      f.input :project, label: I18n.t('label.project'), as: :select, collection: Project.where(client_id: InvoiceHeader.where(id: session[:invoice_header_id]).first.client_id).map { |a| [a.name, a.id] }, input_html: {disabled: true}, required: true
      if f.object.invoicing_milestone_id.blank? and f.object.invoice_adder_type_id.blank?
        f.input :invoicing_milestone, label: I18n.t('label.invoicing_milestone')
        f.input :invoice_adder_type, label: I18n.t('label.invoice_adder_type')
      else
        f.input :invoicing_milestone, label: I18n.t('label.invoicing_milestone'), input_html: {disabled: true}
        f.input :invoicing_milestone_id, as: :hidden
        f.input :invoice_adder_type, label: I18n.t('label.invoice_adder_type'), input_html: {disabled: true}
        f.input :invoice_adder_type_id, as: :hidden
      end
      f.input :narrative, label: I18n.t('label.narrative'), required: true
      f.input :line_amount, label: I18n.t('label.line_amount'), required: true
      f.input :comments, label: I18n.t('label.comments')
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
