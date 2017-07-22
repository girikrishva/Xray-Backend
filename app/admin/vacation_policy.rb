ActiveAdmin.register VacationPolicy do
  menu if: proc { is_menu_authorized? [I18n.t('role.executive')] }, label: I18n.t('menu.vacation_policies'), parent: I18n.t('menu.setup'), priority: 20

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

  permit_params :vacation_code_id, :description, :as_on, :paid, :days_allowed, :comments, :business_unit_id, :updated_by, :ip_address

  config.sort_order = 'as_on_desc_and_business_units.name_asc_and_vacation_codes.name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    VacationPolicy.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_vacation_policies_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = VacationPolicy.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_vacation_policies_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      VacationPolicy.restore(id)
    end
    redirect_to admin_vacation_policies_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_vacation_policy_path
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_vacation_policies_path
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :vacation_code, sortable: 'vacation_codes.name' do |resource|
      resource.vacation_code.name
    end
    column :description
    column :as_on
    column :paid
    column :days_allowed do |element|
      div :style => "text-align: right;" do
        number_with_precision element.days_allowed, precision: 1, delimiter: ','
      end
    end
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_vacation_policy_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.audit_trail'), admin_vacation_policies_audits_path(vacation_policy_id: resource.id)
      end
    end
  end

  filter :id
  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :vacation_code, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.vacation_codes')) }
  filter :description
  filter :as_on
  filter :paid
  filter :days_allowed
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      VacationPolicy.includes [:vacation_code, :business_unit]
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

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url and return if resource.valid?
      end
    end

    def description_for_lookup
      lookup_id = params[:lookup_id]
      description = Lookup.description_for_lookup(lookup_id)
      render json: '{"description": "' + description + '"}'
    end

    def restore
      VacationPolicy.restore(params[:id])
      redirect_to admin_vacation_policies_path
    end
  end

  form do |f|
    f.object.updated_by = current_admin_user.name
    f.object.ip_address = current_admin_user.current_sign_in_ip
    if f.object.as_on.blank?
      f.object.as_on = Date.today
    end
    if f.object.paid.blank?
      f.object.paid = false
    end
    f.inputs do
      if f.object.business_unit_id.blank?
        f.input :business_unit, required: true, as: :select, collection:
                                  Lookup.lookups_for_name(I18n.t('models.business_units'))
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, required: true, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.vacation_code_id.blank?
        f.input :vacation_code, required: true, as: :select, collection:
                                  Lookup.lookups_for_name(I18n.t('models.vacation_codes'))
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :vacation_code, required: true, input_html: {disabled: :true}
        f.input :vacation_code_id, as: :hidden
      end
      f.input :description
      f.input :as_on, as: :datepicker
      f.input :paid
      f.input :days_allowed
      f.input :comments
      f.input :ip_address, as: :hidden
      f.input :updated_by, as: :hidden
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
