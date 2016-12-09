ActiveAdmin.register HolidayCalendar do
  menu if: proc { is_menu_authorized? [I18n.t('role.executive')] }, label: I18n.t('menu.holiday_calendar'), parent: I18n.t('menu.setup'), priority: 30

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
    link_to I18n.t('label.new'), new_admin_holiday_calendar_path
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_holiday_calendars_path
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :name
    column :description
    column :as_on
    column :comments
    actions defaults: true, dropdown: true
  end


  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :name
  filter :as_on
  filter :description
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

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
        f.input :business_unit, required: true, as: :select, collection:
                                  Lookup.lookups_for_name(I18n.t('models.business_units'))
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, required: true, input_html: {disabled: :true}
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
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
