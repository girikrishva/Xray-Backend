ActiveAdmin.register AssignedResource do
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

  permit_params :start_date, :end_date, :number_required, :hours_per_day, :fulfilled, :created_at, :updated_at, :project, :skill_id, :designation_id, :resource_id, :delivery_due_alert, :invoicing_due_alert, :payment_due_alert, :comments, :staffing_requirement_id

  config.sort_order = 'skills.name_asc_and_start_date_asc_and_end_date_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_assigned_resource_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_assigned_resources_path(project_id: nil)
  end

  action_item only: [:show, :edit, :new] do |resource|
    link_to I18n.t('label.back'), admin_assigned_resources_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

# index do
  index as: :grouped_table, group_by_attribute: :skill_name do
    selectable_column
    column :id
    column :project, sortable: 'projects.name' do |resource|
      resource.project.name
    end
    column :designation, sortable: 'designations.name' do |resource|
      resource.designation.name
    end
    column :resource, sortable: 'resources.admin_user.name' do |r|
      r.resource.admin_user.name
    end
    column :as_on
    column :hours_per_day
    column :start_date
    column :end_date
    column :delivery_due_alert
    column :invoicing_due_alert
    column :payment_due_alert
    column :staffing_requirement
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :skill
  filter :designation
  filter :as_on
  filter :hours_per_day
  filter :start_date
  filter :end_date
  filter :delivery_due_alert
  filter :invoicing_due_alert
  filter :payment_due_alert
  filter :staffing_requirement
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :project do
        r.project.name
      end
      row :skill
      row :designation
      row :as_on
      row :hours_per_day
      row :start_date
      row :end_date
      row :delivery_due_alert
      row :invoicing_due_alert
      row :payment_due_alert
      row :staffing_requirement do
        r.staffing_requirement
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

    def scoped_collection
      AssignedResource.includes [:project, :skill, :designation, :resource, :staffing_requirement]
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
  end

  form do |f|
    f.object.project_id = session[:project_id]
    if f.object.new_record?
      f.object.as_on = Date.today
      f.object.hours_per_day = 8
      f.object.start_date = Date.today
      f.object.end_date = Date.today
    end
    f.inputs do
      f.input :project, required: true, input_html: {disabled: :true}
      f.input :project_id, as: :hidden
      if f.object.skill_id.blank?
        f.input :skill, required: true, as: :select, collection:
                          Lookup.lookups_for_name(I18n.t('models.skills'))
                              .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :skill, required: true, input_html: {disabled: :true}
        f.input :skill_id, as: :hidden
      end
      if f.object.designation_id.blank?
        f.input :designation, required: true, as: :select, collection:
                                Lookup.lookups_for_name(I18n.t('models.designations'))
                                    .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :designation, required: true, input_html: {disabled: :true}
        f.input :designation_id, as: :hidden
      end
      if !f.object.new_record?
        f.input :as_on, required: true, label: I18n.t('label.as_on'), as: :datepicker, input_html: {disabled: :true}
        f.input :as_on, as: :hidden
      else
        f.input :as_on, required: true, label: I18n.t('label.as_on'), as: :datepicker
      end
      if f.object.new_record?
        f.input :hours_per_day
      else
        f.input :hours_per_day, required: true, input_html: {readonly: :true}
      end
      if !f.object.new_record?
        f.input :start_date, label: I18n.t('label.start'), as: :datepicker, input_html: {disabled: :true}
        f.input :start_date, as: :hidden
      else
        f.input :start_date, label: I18n.t('label.start'), as: :datepicker
      end
      if !f.object.new_record?
        f.input :end_date, label: I18n.t('label.end'), as: :datepicker, input_html: {disabled: :true}
        f.input :end_date, as: :hidden
      else
        f.input :end_date, label: I18n.t('label.end'), as: :datepicker
      end
      f.input :delivery_due_alert
      f.input :invoicing_due_alert
      f.input :payment_due_alert
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
