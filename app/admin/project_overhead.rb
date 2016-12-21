ActiveAdmin.register ProjectOverhead do
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

  permit_params :project_id, :cost_adder_type_id, :amount_date, :amount, :comments

  config.sort_order = 'amount_date_desc_and_cost_adder_types.name_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    ProjectOverhead.only_deleted.where('project_id = ?', params[:project_id]).order('amount_date desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_project_overheads_path(project_id: params[:project_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_project_overhead_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_project_overheads_path(project_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_project_overheads_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      object = ProjectOverhead.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_project_overheads_path(project_id: session[:project_id])
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      object = ProjectOverhead.restore(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_project_overheads_path(project_id: session[:project_id])
  end

  index as: :grouped_table, group_by_attribute: :project_name do
    selectable_column
    column :id
    column :cost_adder_type
    column :amount_date
    column :amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_project_overhead_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true
    end
  end

  filter :cost_adder_type, collection: proc { CostAdderType.all.order(:name) }
  filter :amount_date
  filter :amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :project do
        r.project.name
      end
      row :cost_adder_type do
        r.cost_adder_type.name
      end
      row :amount_date
      row :amount do
        number_with_precision r.amount, precision: 0, delimiter: ','
      end
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter only: :index do |resource|
      if params.has_key?(:project_id)
        session[:project_id] = params[:project_id]
      else
        redirect_to admin_projects_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"project_id_eq" => params[:project_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      ProjectOverhead.includes [:project, :cost_adder_type]
    end

    def create
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(project_id: session[:project_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(project_id: session[:project_id]) and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(project_id: session[:project_id]) and return if resource.valid?
      end
    end

    def restore
      ProjectOverhead.restore(params[:id])
      redirect_to admin_project_overheads_path(project_id: session[:project_id])
    end
  end

  form do |f|
    f.object.project_id = session[:project_id]
    if f.object.new_record?
      f.object.amount_date = Date.today
    end
    f.inputs do
      f.input :project, required: true, input_html: {disabled: :true}
      f.input :project_id, as: :hidden
      if f.object.cost_adder_type_id.blank?
        f.input :cost_adder_type, required: true, as: :select, collection:
                                    CostAdderType.all.order(:name)
                                        .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :cost_adder_type, required: true, input_html: {disabled: :true}
        f.input :cost_adder_type_id, as: :hidden
      end
      if f.object.new_record?
        f.input :amount_date, as: :datepicker
      else
        f.input :amount_date, required: true, input_html: {readonly: :true}, as: :string
      end
      if f.object.new_record?
        f.input :amount
      else
        f.input :amount, required: true, input_html: {readonly: :true}
      end
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
