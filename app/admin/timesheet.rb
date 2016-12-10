ActiveAdmin.register Timesheet do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, label: I18n.t('menu.timesheets'), parent: I18n.t('menu.operations'), priority: 50

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

  permit_params :assigned_resource_id, :timesheet_date, :hours, :comments

  config.clear_action_items!

  config.sort_order = 'timesheet_date_desc'

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_timesheet_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_timesheets_path
  end

  index do
    selectable_column
    column :id
    column I18n.t('label.assignment'), :assigned_resource do |resource|
      resource.assigned_resource.assigned_resource_name
    end
    column :timesheet_date
    column :hours
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :assigned_resource, label: I18n.t('label.assignment'), collection: AssignedResource.ordered_lookup.map{ |a| [a.assigned_resource_name, a.id]}
  filter :timesheet_date
  filter :hours
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row I18n.t('label.assignment') do
        r.assigned_resource.assigned_resource_name
      end
      row :timesheet_date
      row :hours
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    def scoped_collection
      Timesheet.includes [:assigned_resource]
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
    if f.object.new_record?
      f.object.timesheet_date = Date.today
      f.object.hours = 8
    end
    f.inputs do
      if f.object.new_record?
        f.input :assigned_resource, label: I18n.t('label.assignment'), collection: AssignedResource.ordered_lookup.map { |a| [a.assigned_resource_name, a.id] }, required: true, include_blank: true
        f.input :timesheet_date, as: :datepicker
        f.input :hours
        f.input :comments
      else
        f.input :assigned_resource, collection: AssignedResource.ordered_lookup.map { |a| [a.assigned_resource_name, a.id] }, required: true, include_blank: true, input_html: {disabled: true}
        f.input :assigned_resource_id, as: :hidden
        f.input :timesheet_date, as: :string, input_html: {readonly: true}
        f.input :hours, input_html: {readonly: true}
        f.input :comments
      end
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
