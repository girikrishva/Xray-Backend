ActiveAdmin.register Role do
  menu if: proc { is_menu_authorized? [I18n.t('role.administrator')] }, label: I18n.t('menu.define_roles'), parent: I18n.t('menu.security'), priority: 30

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters

# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  permit_params :name, :description, :rank, :comments, :super_admin, :parent_id, :parent_name

  config.sort_order = 'rank_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    Role.only_deleted
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_roles_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_role_path
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_roles_path
  end

  batch_action :destroy, if: proc{ params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = Role.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_roles_path
  end

  batch_action :restore, if: proc{ params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      object = Role.restore(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_roles_path
  end

  index do
    selectable_column
    column :id
    column :name
    column :super_admin
    column :description
    column :rank
    column :parent_name
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_role_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
      end
    end
  end

  filter :name
  filter :description
  filter :super_admin
  filter :rank
  filter :parent_name, as: :select, collection:
                         proc { Role.all.pluck(:name) }
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
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
      Role.restore(params[:id])
      redirect_to admin_roles_path
    end
  end

  form do |f|
    if f.object.rank.blank?
      f.object.rank = Role.generate_next_rank
    end
    f.inputs do
      f.input :name
      f.input :description
      f.input :super_admin
      f.input :rank
      f.input :parent_id, as: :select, collection:
                            Role.all.map { |a| [a.name, a.id] }, include_blank: true
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
