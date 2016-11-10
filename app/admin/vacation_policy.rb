ActiveAdmin.register VacationPolicy do
  menu label: 'Vacation Policies', parent: 'Setup', priority: 20

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
    link_to "New", new_admin_vacation_policy_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_vacation_policies_path
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
                           proc { Lookup.lookups_for_name('Business Units') }
  filter :vacation_code, collection:
                           proc { Lookup.lookups_for_name('Vacation Codes') }
  filter :description
  filter :as_on
  filter :paid
  filter :days_allowed
  filter :comments

  controller do
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
        f.input :business_unit, as: :select, collection:
                                  Lookup.lookups_for_name('Business Units')
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.vacation_code_id.blank?
        f.input :vacation_code, as: :select, collection:
                                  Lookup.lookups_for_name('Vacation Codes')
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :vacation_code, input_html: {disabled: :true}
        f.input :vacation_code_id, as: :hidden
      end
      f.input :description
      f.input :as_on, as: :datepicker
      f.input :paid
      f.input :days_allowed
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
