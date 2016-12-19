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

  permit_params :client_id, :narrative, :payment_date, :header_amount, :payment_status_id, :comments, :updated_at, :updated_by, :ip_address

  config.sort_order = 'payment_date_desc_and_narrative_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    PaymentHeader.only_deleted
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_payment_headers_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_payment_header_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_payment_headers_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      PaymentHeader.destroy(id)
    end
    redirect_to admin_payment_headers_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      PaymentHeader.restore(id)
    end
    redirect_to admin_payment_headers_path
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
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_payment_header_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item "Audit Trail", admin_payment_headers_audits_path(payment_header_id: resource.id)
        item I18n.t('actions.payment_lines'), admin_payment_lines_path(payment_header_id: resource.id)
      end
    end
  end

  filter :client, collection:
                    proc { Client.ordered_lookup }
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
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

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

    def restore
      PaymentHeader.restore(params[:id])
      redirect_to admin_payment_headers_path
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
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
      f.input :header_amount
      f.input :comments
      f.input :ip_address, as: :hidden
      f.input :updated_by, as: :hidden
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
