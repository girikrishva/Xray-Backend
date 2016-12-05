ActiveAdmin.register PaymentHeader do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: I18n.t('menu.payments'), parent: I18n.t('menu.operations'), priority: 40

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

  permit_params :client_id, :narrative, :payment_date, :amount, :payment_status_id, :comments

  config.sort_order = 'payment_date_desc_and_narrative_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_payment_header_path
  end

  action_item only:  [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_payment_headers_path
  end

  index do
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
    column :amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    actions defaults: true, dropdown: true do |resource|
      # item I18n.t('actions.payment_lines'), admin_invoice_lines_path(invoice_header_id: resource.id)
    end
  end
  filter :client, collection:
                    proc { Client.ordered_lookup }
  filter :narrative
  filter :payment_date
  filter :payment_status
  filter :amount
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
      row :amount
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    def scoped_collection
      PaymentHeader.includes [:client, :payment_status]
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

  form do |f|
    if f.object.payment_status_id.blank?
      f.object.payment_status_id = PaymentStatus.where(name: I18n.t('label.new')).first.id
    end
    if f.object.payment_date.blank?
      f.object.payment_date = Date.today
    end
    f.inputs do
      f.input :client, required: true, as: :select, collection:
                         Client.ordered_lookup.map { |a| [a.name + ' [' + a.business_unit_name + ']', a.id] }, include_blank: true
      f.input :narrative
      f.input :payment_date, required: true, label: I18n.t('label.payment_date'), as: :datepicker
      f.input :payment_status
      f.input :amount
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
