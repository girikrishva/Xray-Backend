ActiveAdmin.register AdminUsersSession do
  menu false

  config.clear_action_items!

  scope I18n.t('label.deleted'), default: false do |resources|
    AdminUsersSession.only_deleted.where('admin_user_id = ?', params[:admin_user_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_admin_users_sessions_path(admin_user_id: params[:admin_user_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_admin_users_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    admin_user_id = AdminUsersSession.without_deleted.find(ids.first).admin_user_id
    ids.each do |id|
      object = AdminUsersSession.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_admin_users_sessions_path(admin_user_id: admin_user_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    admin_user_id = AdminUsersSession.with_deleted.find(ids.first).admin_user_id
    ids.each do |id|
      AdminUsersSession.restore(id)
    end
    redirect_to admin_admin_users_sessions_path(admin_user_id: admin_user_id)
  end

  permit_params :session_ended

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :admin_user_details do
    selectable_column
    column :id
    column :session_started do |resource|
      datetime_as_string(resource.session_started)
    end
    column :session_ended do |resource|
      datetime_as_string(resource.session_ended)
    end
    column :session_length
    column :from_ip_address
    column :avg_session_length
    column :min_session_length
    column :max_session_length
    column :comments
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
      AdminUsersSession.includes [:admin_user]
    end
  end

  filter :session_started
  filter :session_ended
  filter :from_ip_address
  filter :comments
end
