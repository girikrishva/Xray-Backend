ActiveAdmin.register LookupType do
  menu if: proc { is_menu_authorized? [I18n.t('role.director')] }, label: I18n.t('menu.define_lookups'), parent: I18n.t('menu.setup'), priority: 10

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

  permit_params :name, :description, :comments

  config.sort_order = 'name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    LookupType.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_lookup_types_path
  end


  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_lookup_type_path
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_lookup_types_path(lookup_type_id: nil)
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = LookupType.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_lookup_types_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      object = LookupType.restore(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_lookup_types_path
  end

  index do
    selectable_column
    column :id
    column :name
    column :description
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_lookup_type_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.lookups'), admin_lookups_path(lookup_type_id: resource)
      end
    end
  end

  filter :name
  filter :description
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.director')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

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

    def restore
      LookupType.restore(params[:id])
      redirect_to admin_lookup_types_path
    end
  end

  form do |f|
    f.inputs
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
