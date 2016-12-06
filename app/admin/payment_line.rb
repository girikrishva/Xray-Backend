ActiveAdmin.register PaymentLine do
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

  permit_params :payment_header_id, :invoice_line_id, :narrative, :line_amount, :comments

  config.sort_order = 'narrative_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_payment_line_path(payment_header_id: session[:payment_header_id]) if session.has_key?(:payment_header_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_payment_lines_path(payment_header_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_payment_lines_path(payment_header_id: session[:payment_header_id]) if session.has_key?(:payment_header_id)
  end

  index as: :grouped_table, group_by_attribute: :payment_header_name do
    selectable_column
    column :id
    column :invoice_line
    column :narrative
    column :line_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.line_amount, precision: 0, delimiter: ','
      end
    end
    column :unapplied_amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.invoice_line.unapplied_amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    actions defaults: true, dropdown: true do |resource|
    end
  end

  filter :invoice_line
  filter :narrative
  filter :line_amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :invoice_line
      row :narrative
      row :line_amount
      row :unapplied_amount
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if params.has_key?(:payment_header_id)
        session[:payment_header_id] = params[:payment_header_id]
      else
        redirect_to admin_payment_headers_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"payment_header_id_eq" => params[:payment_header_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end


    def scoped_collection
      PaymentLine.includes [:payment_header, :invoice_line]
    end

    def create
      super do |format|
        redirect_to collection_url(payment_header_id: session[:payment_header_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url(payment_header_id: session[:payment_header_id]) and return if resource.valid?
      end
    end
  end

  form do |f|
    f.object.payment_header_id = session[:payment_header_id]
    f.inputs do
      f.input :payment_header_id, label: I18n.t('label.payment_header'), as: :select, collection: PaymentHeader.where(id: session[:payment_header_id]).map { |a| [a.payment_header_name, a.id] }, input_html: {disabled: true}, required: true
      f.input :payment_header_id, as: :hidden, required: true
      if f.object.new_record?
        f.input :invoice_line, label: I18n.t('label.invoice_line'), as: :select, collection: InvoiceLine.invoice_lines_for_client(session[:payment_header_id]).map { |a| [a.name, a.id] }, required: true
      else
        f.input :invoice_line, label: I18n.t('label.invoice_line'), as: :select, collection: InvoiceLine.invoice_lines_for_client(session[:payment_header_id]).map { |a| [a.name, a.id] }, input_html: {disabled: true}, required: true
        f.input :invoice_line_id, as: :hidden
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
