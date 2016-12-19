ActiveAdmin.register HolidayCalendarsAudit do
  menu false

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    HolidayCalendarsAudit.only_deleted.where('holiday_calendar_id = ?', params[:holiday_calendar_id]).order('id desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_holiday_calendars_audits_path(holiday_calendar_id: params[:holiday_calendar_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_holiday_calendars_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    holiday_calendar_id = HolidayCalendarsAudit.without_deleted.find(ids.first).holiday_calendar_id
    ids.each do |id|
      HolidayCalendarsAudit.destroy(id)
    end
    redirect_to admin_holiday_calendars_audits_path(holiday_calendar_id: holiday_calendar_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    holiday_calendar_id = HolidayCalendarsAudit.with_deleted.find(ids.first).holiday_calendar_id
    ids.each do |id|
      HolidayCalendarsAudit.restore(id)
    end
    redirect_to admin_holiday_calendars_audits_path(holiday_calendar_id: holiday_calendar_id)
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
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_holiday_calendars_audit_path(resource.id)
    end
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

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

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
