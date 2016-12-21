ActiveAdmin.register ProjectType do
  menu if: proc { is_menu_authorized? [I18n.t('role.executive')] }, label: I18n.t('menu.project_types'), parent: I18n.t('menu.setup'), priority: 40

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

  permit_params :business_unit_id, :project_type_code_id, :description, :billed, :comments

  config.sort_order = 'business_units.name_asc_and_project_type_codes.name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    ProjectType.only_deleted
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_project_types_path
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_project_type_path
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_project_types_path
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = ProjectType.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_project_types_path
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      object = ProjectType.restore(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_project_types_path
  end

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :business_unit, sortable: 'business_units.name' do |resource|
      resource.business_unit.name
    end
    column :project_type_code, sortable: 'project_type_codes.name' do |resource|
      resource.project_type_code.name
    end
    column :description
    column :billed
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_project_type_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true
    end
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :project_type_code, collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }
  filter :description
  filter :billed
  filter :comments

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      ProjectType.includes [:project_type_code, :business_unit]
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

    def description_for_lookup
      lookup_id = params[:lookup_id]
      description = Lookup.description_for_lookup(lookup_id)
      render json: '{"description": "' + description + '"}'
    end

    def restore
      ProjectType.restore(params[:id])
      redirect_to admin_project_types_path
    end
  end

  form do |f|
    if f.object.billed.blank?
      f.object.billed = true
    end
    f.inputs do
      if f.object.business_unit_id.blank?
        f.input :business_unit, required: true, as: :select, collection:
                                  Lookup.lookups_for_name(I18n.t('models.business_units'))
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, required: true, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.project_type_code_id.blank?
        f.input :project_type_code, required: true, as: :select, collection:
                                      Lookup.lookups_for_name(I18n.t('models.project_types'))
                                          .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :project_type_code, required: true, input_html: {disabled: :true}
        f.input :project_type_code_id, as: :hidden
      end
      f.input :description
      f.input :billed
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
