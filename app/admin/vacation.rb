ActiveAdmin.register Vacation do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, label: I18n.t('menu.vacations'), parent: I18n.t('menu.operations'), priority: 60

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

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Vacation.only_deleted.order('request_date desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_vacations_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_vacation_path
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_vacations_path
  end

  batch_action :revert, if: proc { params[:scope] != 'deleted' }, priority: 4 do |ids|
    ids.each do |id|
      vacation = Vacation.find(id)
      vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.pending')).first.id
      vacation.save
    end
    redirect_to collection_url
  end

  batch_action :cancel, if: proc { params[:scope] != 'deleted' }, priority: 3 do |ids|
    ids.each do |id|
      vacation = Vacation.find(id)
      vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.canceled')).first.id
      vacation.save
    end
    redirect_to collection_url
  end

  batch_action :reject, if: proc { params[:scope] != 'deleted' }, priority: 2 do |ids|
    ids.each do |id|
      vacation = Vacation.find(id)
      vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.rejected')).first.id
      vacation.save
    end
    redirect_to collection_url
  end

  batch_action :approve, if: proc { params[:scope] != 'deleted' }, priority: 1 do |ids|
    ids.each do |id|
      vacation = Vacation.find(id)
      vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.approved')).first.id
      vacation.save
    end
    redirect_to collection_url
  end

  permit_params :admin_user_id, :vacation_code_id, :narrative, :request_date, :start_date, :end_date, :hours_per_day, :approval_status_id, :comments

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      Vacation.destroy(id)
    end
    redirect_to admin_vacations_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      Vacation.restore(id)
    end
    redirect_to admin_vacations_path
  end

  index as: :grouped_table, group_by_attribute: :approval_status_name do
    selectable_column
    column :id
    column :request_date
    column :user, sortable: 'admin_users.name' do |resource|
      resource.user.name
    end
    column :vacation_code, sortable: 'vacation_codes.description' do |resource|
      resource.vacation_code.description
    end
    column :narrative
    column :start_date
    column :end_date
    column :hours_per_day
    column :balance_days
    column :requested_days
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_vacation_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.approve_vacation'), admin_api_approve_vacation_path(vacation_id: resource.id), method: :post
        item I18n.t('actions.reject_vacation'), admin_api_reject_vacation_path(vacation_id: resource.id), method: :post
        item I18n.t('actions.cancel_vacation'), admin_api_cancel_vacation_path(vacation_id: resource.id), method: :post
        item I18n.t('actions.revert_vacation'), admin_api_make_vacation_pending_path(vacation_id: resource.id), method: :post
      end
    end
  end

  filter :request_date
  filter :user, collection: proc { AdminUser.ordered_lookup_of_users_as_resource }
  filter :vacation_code, collection: Lookup.lookups_for_name(I18n.t('models.vacation_codes')).map { |a| [a.description, a.id] }
  filter :narrative
  filter :start_date
  filter :end_date
  filter :hours_per_day
  filter :approval_status, if: proc { !params.has_key?('scope') || params[:scope] == 'all_view' }
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :request_date
      row :user do
        r.user.name
      end
      row :vacation_code do
        r.vacation_code.description
      end
      row :narrative
      row :start_date
      row :end_date
      row :hours_per_day
      row :approval_status do
        r.approval_status.name
      end
      row :eligible_days
      row :holidays
      row :availed_days
      row :balance_days
      row :requested_days
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      Vacation.includes [:user, :vacation_code, :approval_status]
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

    def approve_vacation
      if params.has_key?(:vacation_id)
        vacation_id = params[:vacation_id]
        vacation = Vacation.find(vacation_id)
        vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.approved')).first.id
        vacation.save
        redirect_to admin_vacations_path
      end
    end

    def reject_vacation
      if params.has_key?(:vacation_id)
        vacation_id = params[:vacation_id]
        vacation = Vacation.find(vacation_id)
        vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.rejected')).first.id
        vacation.save
        redirect_to admin_vacations_path
      end
    end

    def cancel_vacation
      if params.has_key?(:vacation_id)
        vacation_id = params[:vacation_id]
        vacation = Vacation.find(vacation_id)
        vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.canceled')).first.id
        vacation.save
        redirect_to admin_vacations_path
      end
    end

    def make_vacation_pending
      if params.has_key?(:vacation_id)
        vacation_id = params[:vacation_id]
        vacation = Vacation.find(vacation_id)
        vacation.approval_status_id = ApprovalStatus.where('name = ?', I18n.t('label.pending')).first.id
        vacation.save
        redirect_to admin_vacations_path
      end
    end

    def restore
      Vacation.restore(params[:id])
      redirect_to admin_vacations_path
    end
  end

  form do |f|
    if f.object.new_record?
      f.object.admin_user_id = current_admin_user.id
      f.object.request_date = Date.today
      f.object.start_date = Date.today
      f.object.end_date = Date.today
      f.object.hours_per_day = 8
      f.object.approval_status_id = ApprovalStatus.where(name: I18n.t('label.pending')).first.id
    end
    f.inputs do
      if f.object.new_record?
        f.input :user, collection: AdminUser.ordered_lookup_of_users_as_resource.map { |a| [a.name, a.id] }, required: true
      else
        f.input :user, collection: AdminUser.ordered_lookup_of_users_as_resource.map { |a| [a.name, a.id] }, required: true, input_html: {disabled: true}
        f.input :admin_user_id, as: :hidden
      end
      if f.object.new_record?
        f.input :vacation_code, collection: VacationCode.all.map { |a| [a.description, a.id] }, required: true
      else
        f.input :vacation_code, collection: VacationCode.all.map { |a| [a.description, a.id] }, required: true, input_html: {disabled: true}
      end
      f.input :request_date, as: :hidden
      if f.object.new_record?
        f.input :narrative
        f.input :start_date, as: :datepicker
        f.input :end_date, as: :datepicker
        f.input :hours_per_day
      else
        f.input :narrative, as: :string, input_html: {readonly: true}
        f.input :start_date, as: :string, input_html: {readonly: true}
        f.input :end_date, as: :string, input_html: {readonly: true}
        f.input :hours_per_day, as: :string, input_html: {readonly: true}
      end
      f.input :approval_status_id, as: :hidden
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
