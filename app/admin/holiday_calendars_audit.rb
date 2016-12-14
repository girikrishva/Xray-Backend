ActiveAdmin.register HolidayCalendarsAudit do
  menu false

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_holiday_calendars_path
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :name
    column :description
    column :as_on
    column :comments
    column :audit_details
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:holiday_calendar_id)
        redirect_to admin_holiday_calendars_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"holiday_calendar_id_eq" => params[:holiday_calendar_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_action
      HolidayCalendarsAudit.includes [:business_unit, :holiday_calendar]
    end
  end

  filter :name
  filter :description
  filter :as_on
  filter :paid
  filter :comments
  filter :updated_at
  filter :updated_by
  filter :ip_address
end
