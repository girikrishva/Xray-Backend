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

  permit_params :vacation_code_id, :description, :as_on, :paid, :days_allowed, :comments, :business_unit_id

  config.sort_order = 'as_on_desc_and_business_units.name_asc_and_vacation_codes.name_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_vacation_policy_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), admin_vacation_policies_path
  end

  index do
    selectable_column
    column :id
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :vacation_code, sortable: 'vacation_codes.name' do |resource|
      resource.vacation_code.name
    end
    column :description
    column :as_on
    column :paid
    column :days_allowed
    column :comments
    actions defaults: true, dropdown: true
  end

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

    def scoped_collection
      VacationPolicy.includes  [:vacation_code, :business_unit]
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

    def description_for_lookup
      lookup_id = params[:lookup_id]
      description = Lookup.description_for_lookup(lookup_id)
      render json: '{"description": "' + description + '"}'
    end
  end

  form do |f|
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
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
      f.cancel_link
    end
  end
end
