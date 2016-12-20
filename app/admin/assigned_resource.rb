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

  permit_params :start_date, :end_date, :number_required, :hours_per_day, :fulfilled, :created_at, :updated_at, :project, :skill_id, :designation_id, :resource_id, :delivery_due_alert, :invoicing_due_alert, :payment_due_alert, :comments, :staffing_requirement_id, :project_id, :skill_code, :designation_code, :as_on, :bill_rate, :cost_rate

  config.sort_order = 'skills.name_asc_and_start_date_asc_and_end_date_asc'

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    AssignedResource.only_deleted.where('project_id = ?', params[:project_id]).order('deleted_at desc')
  end

  action_item only: :index, if: proc { current_admin_user.role.super_admin } do |resource|
    link_to I18n.t('label.all'), admin_assigned_resources_path(project_id: params[:project_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_assigned_resource_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_assigned_resources_path(project_id: nil)
  end

  action_item only: [:show, :edit, :new, :create] do |resource|
    link_to I18n.t('label.back'), admin_assigned_resources_path(project_id: session[:project_id]) if session.has_key?(:project_id)
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    ids.each do |id|
      AssignedResource.destroy(id)
    end
    redirect_to admin_assigned_resources_path(project_id: session[:project_id])
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    ids.each do |id|
      AssignedResource.restore(id)
    end
    redirect_to admin_assigned_resources_path(project_id: session[:project_id])
  end

  index as: :grouped_table, group_by_attribute: :skill_name, default: :true do
    if params[:scope] == 'detailed_view'
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.staffing_fulfilled'), admin_api_staffing_fulfilled_path(staffing_requirement_id: resource.staffing_requirement_id), method: :post
      end
    end
    selectable_column
    column :staffing_requirement, sortable: 'staffing_requirements.name' do |r|
      r.staffing_requirement.name
    end
    column :id
    column :project, sortable: 'projects.name' do |resource|
      resource.project.name
    end
    column :resource, sortable: 'resources.admin_user.name' do |r|
      r.resource.admin_user.name
    end
    column :as_on
    column :hours_per_day
    column :start_date
    column :end_date
    column :bill_rate, :sortable => 'bill_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.bill_rate, precision: 0, delimiter: ','
      end
    end
    column :cost_rate, :sortable => 'cost_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.cost_rate, precision: 0, delimiter: ','
      end
    end
    column :comments
    if params[:scope] == 'deleted'
      actions defaults: false, dropdown: true do |resource|
        item I18n.t('actions.restore'), admin_api_restore_assigned_resource_path(id: resource.id), method: :post
      end
    else
      actions defaults: true, dropdown: true do |resource|
        item I18n.t('actions.staffing_fulfilled'), admin_api_staffing_fulfilled_path(staffing_requirement_id: resource.staffing_requirement_id), method: :post
      end
    end
  end

  filter :staffing_requirement, collection: proc { StaffingRequirement.ordered_lookup(Project.find(session[:project_id]).pipeline_id) }
  filter :fulfilled
  filter :skill_code
  filter :designation_code
  filter :as_on
  filter :hours_per_day
  filter :start_date
  filter :end_date
  filter :bill_rate
  filter :cost_rate
  filter :delivery_due_alert
  filter :invoicing_due_alert
  filter :payment_due_alert
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :project do
        r.project.name
      end
      row :skill_code
      row :designation_code
      row :as_on
      row :hours_per_day
      row :start_date
      row :end_date
      row :bill_rate do
        number_with_precision r.bill_rate, precision: 0, delimiter: ','
      end
      row :cost_rate do
        number_with_precision r.cost_rate, precision: 0, delimiter: ','
      end
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

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      AssignedResource.includes [:project, :skill_code, :designation_code, :resource, :staffing_requirement]
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

    def skill_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      skill_id = Skill.find(StaffingRequirement.find(staffing_requirement_id).skill_id).id
      render json: '{"skill_id": "' + skill_id.to_s + '"}'
    end

    def designation_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      designation_id = Designation.find(StaffingRequirement.find(staffing_requirement_id).designation_id).id
      render json: '{"designation_id": "' + designation_id.to_s + '"}'
    end

    def start_date_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      start_date = StaffingRequirement.find(staffing_requirement_id).start_date
      render json: '{"start_date": "' + start_date.to_s + '"}'
    end

    def end_date_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      end_date = StaffingRequirement.find(staffing_requirement_id).end_date
      render json: '{"end_date": "' + end_date.to_s + '"}'
    end

    def hours_per_day_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      hours_per_day = StaffingRequirement.find(staffing_requirement_id).hours_per_day
      render json: '{"hours_per_day": "' + hours_per_day.to_s + '"}'
    end

    def staffing_fulfilled
      if params.has_key?(:staffing_requirement_id)
        staffing_requirement_id = params[:staffing_requirement_id]
        staffing_requirement = StaffingRequirement.find(staffing_requirement_id)
        staffing_requirement.fulfilled = true
        staffing_requirement.save
        redirect_to admin_assigned_resources_path(project_id: session[:project_id])
      end
    end

    def restore
      AssignedResource.restore(params[:id])
      redirect_to admin_assigned_resources_path(project_id: session[:project_id])
    end
  end

  form do |f|
    f.object.project_id = session[:project_id]
    if f.object.new_record?
      f.object.as_on = Date.today
    end
    f.inputs do
      f.input :project, required: true, input_html: {disabled: :true}
      f.input :project_id, as: :hidden
      if f.object.staffing_requirement_id.blank?
        f.input :staffing_requirement, required: true, as: :select, collection:
                                         StaffingRequirement.ordered_lookup(f.object.project.pipeline_id)
                                             .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :staffing_requirement, required: true, input_html: {disabled: :true}
        f.input :staffing_requirement_id, as: :hidden
      end
      f.input :skill_id, as: :hidden
      f.input :designation_id, as: :hidden
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
      if !f.object.new_record?
        f.input :as_on, required: true, label: I18n.t('label.as_on'), as: :string, input_html: {readonly: :true}
      else
        f.input :as_on, required: true, label: I18n.t('label.as_on'), as: :datepicker
      end
      f.input :resource, required: true, input_html: {disabled: :true}
      if f.object.new_record?
        f.input :bill_rate
      else
        f.input :bill_rate, required: true, input_html: {readonly: :true}
      end
      if f.object.new_record?
        f.input :cost_rate
      else
        f.input :cost_rate, required: true, input_html: {readonly: :true}
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
