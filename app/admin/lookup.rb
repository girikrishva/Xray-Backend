ActiveAdmin.register Lookup do
  menu false
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

  permit_params :name, :description, :rank, :comments, :lookup_type_id, :extra

  config.sort_order = 'rank_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Lookup.only_deleted.where('lookup_type_id = ?', session[:lookup_type_id]).order('rank desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_lookups_path(lookup_type_id: params[:lookup_type_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_lookup_path(lookup_type_id: session[:lookup_type_id]) if session.has_key?(:lookup_type_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_lookup_types_path(lookup_type_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_lookups_path(lookup_type_id: session[:lookup_type_id]) if session.has_key?(:lookup_type_id)
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = Lookup.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_lookups_path(lookup_type_id: session[:lookup_type_id])
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      object = Lookup.restore(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_lookups_path(lookup_type_id: session[:lookup_type_id])
  end

  index as: :grouped_table, group_by_attribute: :lookup_type_name do
    selectable_column
    column :id
    column :name
    column :description
    column :rank
    column :extra
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_lookup_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true
    end
  end

  show do |r|
    attributes_table_for r do
      row :id
      row :name
      row :description
      row :rank
      row :extra
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.director')])
    end

    before_filter only: :index do |resource|
      if params.has_key?(:lookup_type_id)
        session[:lookup_type_id] = params[:lookup_type_id]
      else
        redirect_to admin_lookup_types_path
      end
      # if filter button wasn't clicked
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"lookup_type_id_eq" => session[:lookup_type_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      resource_class.includes(:lookup_type)
    end

    def create
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(lookup_type_id: session[:lookup_type_id]) and return if resource.valid?
      end
    end

    def restore
      Lookup.restore(params[:id])
      redirect_to admin_lookups_path(lookup_type_id: session[:lookup_type_id])
    end
  end

  filter :name
  filter :description
  filter :rank
  filter :extra
  filter :comments

  form do |f|
    if session.has_key?(:lookup_type_id)
      f.object.lookup_type_id = session[:lookup_type_id]
      if f.object.rank.blank?
        f.object.rank = Lookup.max_rank_for_lookup_type(session[:lookup_type_id])
      end
    end
    f.inputs do
      f.input :lookup_type, required: true, label: I18n.t('label.type') + '*', input_html: {disabled: :true}
      f.input :lookup_type_id, as: :hidden
      f.input :name
      f.input :description
      f.input :rank
      f.input :extra
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
