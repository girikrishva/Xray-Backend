ActiveAdmin.register AdminUsersAudit do
  menu false

  config.clear_action_items!

  scope I18n.t('label.deleted'), default: false do |resources|
    AdminUsersAudit.only_deleted.where('admin_user_id = ?', params[:admin_user_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_admin_users_audits_path(admin_user_id: params[:admin_user_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_admin_users_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    admin_user_id = AdminUsersAudit.without_deleted.find(ids.first).admin_user_id
    ids.each do |id|
      object = AdminUsersAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_admin_users_audits_path(admin_user_id: admin_user_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    admin_user_id = AdminUsersAudit.with_deleted.find(ids.first).admin_user_id
    ids.each do |id|
      AdminUsersAudit.restore(id)
    end
    redirect_to admin_admin_users_audits_path(admin_user_id: admin_user_id)
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :email do
    selectable_column
    column :id
    column :name
    column :associate_no
    column :active
    column :role, sortable: 'roles.name' do |resource|
      resource.role.name
    end
    column :manager, sortable: 'admin_users.name' do |resource|
      resource.manager.name rescue nil
    end
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :department, sortable: 'departments.name' do |resource|
      resource.department.name
    end
    column :designation, sortable: 'designations.name' do |resource|
      resource.designation.name
    end
    column :date_of_joining
    column :date_of_leaving
    column :bill_rate do |element|
      div :style => "text-align: right;" do
        number_with_precision element.bill_rate, precision: 0, delimiter: ','
      end
    end
    column :cost_rate do |element|
      div :style => "text-align: right;" do
        number_with_precision element.cost_rate, precision: 0, delimiter: ','
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_admin_users_audit_path(resource.id)
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Administrator"])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:admin_user_id)
        redirect_to admin_admin_users_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"admin_user_id_eq" => params[:admin_user_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_action
      AdminUsersAudit.includes [:role, :business_unit, :department, :designation, :admin_user]
    end

    def active_users_outflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.active_users_outflow(from_date, to_date)
      render json: result
    end

    def inactive_users_outflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.inactive_users_outflow(from_date, to_date)
      render json: result
    end

    def all_users_outflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.all_users_outflow(from_date, to_date)
      render json: result
    end

    def active_users_inflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.active_users_inflow(from_date, to_date)
      render json: result
    end

    def inactive_users_inflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.inactive_users_inflow(from_date, to_date)
      render json: result
    end

    def all_users_inflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.all_users_inflow(from_date, to_date)
      render json: result
    end

    def active_users_netflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.active_users_netflow(from_date, to_date)
      render json: result
    end

    def inactive_users_netflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.inactive_users_netflow(from_date, to_date)
      render json: result
    end

    def all_users_netflow
      from_date = params[:from_date]
      to_date = params[:to_date]
      result = AdminUsersAudit.all_users_netflow(from_date, to_date)
      render json: result
    end
  end

  filter :id
  filter :name
  filter :associate_no
  filter :active
  filter :role
  filter :manager
  filter :business_unit
  filter :department
  filter :designation
  filter :date_of_joining
  filter :date_of_leaving
  filter :updated_at
  filter :updated_by
  filter :ip_address
  filter :bill_rate
  filter :cost_rate
  filter :comments
end
