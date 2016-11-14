ActiveAdmin.register HolidayCalendar do
  menu if: proc { is_menu_authorized? ["Executive"] }, label: 'Holiday Calendar', parent: 'Setup', priority: 30

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

  permit_params :name, :as_on, :description, :comments, :business_unit_id

  config.sort_order = 'as_on_desc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_holiday_calendar_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_holiday_calendars_path
  end

  index do
    selectable_column
    column :id
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :name
    column :description
    column :as_on
    column :comments
    actions defaults: true, dropdown: true
  end


  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name('Business Units') }
  filter :name
  filter :as_on
  filter :description
  filter :comments

  controller do
    def scoped_collection
      HolidayCalendar.includes(:business_unit)
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
    f.inputs do
      if f.object.business_unit_id.blank?
        f.input :business_unit, as: :select, collection:
                                  Lookup.lookups_for_name('Business Units')
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.name.blank?
        f.input :name
      else
        f.input :name, input_html: {disabled: :true}
        f.input :name, as: :hidden
      end
      f.input :description
      f.input :as_on, as: :datepicker
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
