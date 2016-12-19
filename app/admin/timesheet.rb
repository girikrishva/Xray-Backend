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

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Timesheet.only_deleted
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_timesheets_path
  end

  batch_action :revert, if: proc { params[:scope] != 'deleted' }, priority: 4 do |ids|
    ids.each do |id|
      timesheet = Timesheet.find(id)
      timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.pending')).first.id
      timesheet.save
    end
    redirect_to collection_url
  end

  batch_action :cancel, if: proc { params[:scope] != 'deleted' }, priority: 3 do |ids|
    ids.each do |id|
      timesheet = Timesheet.find(id)
      timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.canceled')).first.id
      timesheet.save
    end
    redirect_to collection_url
  end

  batch_action :reject, if: proc { params[:scope] != 'deleted' }, priority: 2 do |ids|
    ids.each do |id|
      timesheet = Timesheet.find(id)
      timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.rejected')).first.id
      timesheet.save
    end
    redirect_to collection_url
  end

  batch_action :approve, if: proc { params[:scope] != 'deleted' }, priority: 1 do |ids|
    ids.each do |id|
      timesheet = Timesheet.find(id)
      timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.approved')).first.id
      timesheet.save
    end
    redirect_to collection_url
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      Timesheet.destroy(id)
    end
    redirect_to admin_timesheets_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      Timesheet.restore(id)
    end
    redirect_to admin_timesheets_path
  end

  permit_params :assigned_resource_id, :timesheet_date, :hours, :approval_status_id, :comments

  config.clear_action_items!

  config.sort_order = 'timesheet_date_desc'

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Timesheet.only_deleted
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_timesheets_path
  end

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
    column :approval_status
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_timesheet_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.approve_timesheet'), admin_api_approve_timesheet_path(timesheet_id: resource.id), method: :post
        item I18n.t('actions.reject_timesheet'), admin_api_reject_timesheet_path(timesheet_id: resource.id), method: :post
        item I18n.t('actions.cancel_timesheet'), admin_api_cancel_timesheet_path(timesheet_id: resource.id), method: :post
        item I18n.t('actions.revert_timesheet'), admin_api_make_timesheet_pending_path(timesheet_id: resource.id), method: :post
      end
    end
  end

  filter :assigned_resource, label: I18n.t('label.assignment'), collection: AssignedResource.ordered_lookup.map { |a| [a.assigned_resource_name, a.id] }
  filter :timesheet_date
  filter :hours
  filter :approval_status
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row I18n.t('label.assignment') do
        r.assigned_resource.assigned_resource_name
      end
      row :timesheet_date
      row :hours
      row :approval_status
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

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

    def approve_timesheet
      if params.has_key?(:timesheet_id)
        timesheet_id = params[:timesheet_id]
        timesheet = Timesheet.find(timesheet_id)
        timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.approved')).first.id
        timesheet.save
        redirect_to admin_timesheets_path
      end
    end

    def reject_timesheet
      if params.has_key?(:timesheet_id)
        timesheet_id = params[:timesheet_id]
        timesheet = Timesheet.find(timesheet_id)
        timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.rejected')).first.id
        timesheet.save
        redirect_to admin_timesheets_path
      end
    end

    def cancel_timesheet
      if params.has_key?(:timesheet_id)
        timesheet_id = params[:timesheet_id]
        timesheet = Timesheet.find(timesheet_id)
        timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.canceled')).first.id
        timesheet.save
        redirect_to admin_timesheets_path
      end
    end

    def make_timesheet_pending
      if params.has_key?(:timesheet_id)
        timesheet_id = params[:timesheet_id]
        timesheet = Timesheet.find(timesheet_id)
        timesheet.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.pending')).first.id
        timesheet.save
        redirect_to admin_timesheets_path
      end
    end

    def restore
      Timesheet.restore(params[:id])
      redirect_to admin_timesheets_path
    end
  end

  form do |f|
    if f.object.new_record?
      f.object.timesheet_date = Date.today
      f.object.hours = 8
      f.object.approval_status_id = ApprovalStatus.where(name: I18n.t('label.pending')).first.id
    end
    f.inputs do
      if f.object.new_record?
        f.input :assigned_resource, label: I18n.t('label.assignment'), collection: AssignedResource.ordered_lookup.map { |a| [a.assigned_resource_name, a.id] }, required: true, include_blank: true
        f.input :timesheet_date, as: :datepicker
        f.input :hours
        f.input :approval_status_id, as: :hidden
        f.input :comments
      else
        f.input :assigned_resource, collection: AssignedResource.ordered_lookup.map { |a| [a.assigned_resource_name, a.id] }, required: true, include_blank: true, input_html: {disabled: true}
        f.input :assigned_resource_id, as: :hidden
        f.input :timesheet_date, as: :string, input_html: {readonly: true}
        f.input :hours, input_html: {readonly: true}
        f.input :approval_status_id, as: :hidden
        f.input :comments
      end
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
