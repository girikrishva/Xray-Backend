ActiveAdmin.register InvoicingMilestone do
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

  permit_params :project_id, :name, :description, :amount, :due_date, :last_reminder_date, :completion_date, :comments

  config.sort_order = 'due_date_desc_and_name_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_invoicing_milestone_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_invoicing_milestones_path(project_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_invoicing_milestones_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  index as: :grouped_table, group_by_attribute: :project_name do
    selectable_column
    column :id
    column :name
    column :description
    column :due_date
    column :amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.amount, precision: 0, delimiter: ','
      end
    end
    column :uninvoiced do |element|
      div :style => "text-align: right;" do
        number_with_precision element.uninvoiced, precision: 0, delimiter: ','
      end
    end
    column :last_reminder_date
    column :completion_date
    column :comments
    actions defaults: true, dropdown: true do |resource|
      item I18n.t('actions.delivery_milestones'), admin_invoicing_delivery_milestones_path(project_id: session[:project_id], invoicing_milestone_id: resource.id)
    end
  end

  filter :name
  filter :description
  filter :amount
  filter :due_date
  filter :last_reminder_date
  filter :completion_date
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :project do
        r.project.name
      end
      row :name
      row :description
      row :amount
      row :uninvoiced
      row :due_date
      row :last_reminder_date
      row :completion_date
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


    def scoped_collection
      InvoicingMilestone.includes [:project]
    end

    def create
      super do |format|
        redirect_to collection_url(project_id: session[:project_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url(project_id: session[:project_id]) and return if resource.valid?
      end
    end

    def invoicing_milestones_for_project
      project_id = params[:project_id]
      invoicing_milestones = InvoicingMilestone.invoicing_milestones_for_project(project_id)
      render json: '{"invoicing_milestones": ' + invoicing_milestones.to_json.to_json + '}'
    end
  end

  form do |f|
    f.object.project_id = session[:project_id]
    if f.object.new_record?
      f.object.due_date = Date.today
    end
    f.inputs do
      f.input :project, required: true, input_html: {disabled: :true}
      f.input :project_id, as: :hidden
      f.input :name
      f.input :description
      f.input :amount
      f.input :due_date, as: :datepicker
      f.input :last_reminder_date, as: :string, input_html: {readonly: :true}
      f.input :completion_date, as: :datepicker
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
