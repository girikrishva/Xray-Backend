ActiveAdmin.register StaffingRequirement, as:"Resource Forecast" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Resource Forecast", parent: I18n.t('menu.reports'), priority: 10
config.batch_actions = false
  actions :index
  index do
    # selectable_column
    script :src => javascript_path('resource_forecast.js'), :type => "text/javascript"
   
     column "Technology" do |element|
      div  do
        element.skill_name
      end
    end
    column :designation, sortable: 'designations.name' do |resource|
      resource.designation.name
    end
    column "Staffing Required" do |element|
      div  class:"staffing_required text_link","data-popup-open":"popup-1" do
        StaffingRequirement.staffing_required(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"]
      end
    end
   column "Staffing Fulfilled" do |element|
      div  class:"staffing_fulfilled text_link","data-popup-open":"popup-1" do
        StaffingRequirement.staffing_fulfilled(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"]
      end
    end

    column "Staffing Gap" do |element|
      div  do
        StaffingRequirement.staffing_required(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"].to_i - StaffingRequirement.staffing_fulfilled(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"].to_i
      end
    end

     column "Deployable Resources" do |element|
      div  class:"deployable_resources text_link","data-popup-open":"popup-1" do
        StaffingRequirement.deployable_resources(element.skill_id,element.designation_id,element.start_date,element.end_date,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"]
      end
    end

     column "Recruitment Need" do |element|
      div  do
        (StaffingRequirement.staffing_required(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"].to_i - StaffingRequirement.staffing_fulfilled(element.skill_id,element.designation_id,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"].to_i
        )-StaffingRequirement.deployable_resources(element.skill_id,element.designation_id,element.start_date,element.end_date,(params["q"]["as_on_gteq_date"] rescue nil), false)["count"]
      end
    end
    # column :start_date
    # column :end_date
    # column :fulfilled
      div class:"popup","data-popup": "popup-1" do
      div class:"popup-inner",style:"overflow : auto;" do
        span class:"ajax_content" do 
        end
          a class:"popup-close","data-popup-close":"popup-1","href":"#" do
            "Close"
          end
      end
    end
  end

  filter :as_on, :as => :date_range

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      StaffingRequirement.joins(:skill, :designation).where('? between start_date and end_date', (params["q"]["as_on_gteq_date"] rescue nil)).uniq
    end

    def create
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(pipeline_id: session[:pipeline_id]) and return if resource.valid?
      end
    end

    def update
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(pipeline_id: session[:pipeline_id]) and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        if !resource.errors.empty?
          flash[:error] = resource.errors.full_messages.to_sentence
        end
        redirect_to collection_url(pipeline_id: session[:pipeline_id]) and return if resource.valid?
      end
    end

    def restore
      StaffingRequirement.restore(params[:id])
      redirect_to admin_staffing_requirements_path(pipeline_id: session[:pipeline_id])
    end

    def staffing_forecast
      as_on = params[:as_on]
      with_details = params[:with_details]
      result = StaffingRequirement.staffing_forecast(as_on, with_details)
      render json: result
    end
  end

  form do |f|
    f.object.pipeline_id = session[:pipeline_id]
    if f.object.new_record?
      f.object.number_required = 1
      f.object.hours_per_day = Rails.configuration.max_work_hours_per_day
      f.object.start_date = Date.today
      f.object.end_date = Date.today
    end
    f.inputs do
      f.input :pipeline, required: true, input_html: {disabled: :true}
      f.input :pipeline_id, as: :hidden
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
      if f.object.new_record?
        f.input :number_required
        f.input :hours_per_day
      else
        f.input :number_required, required: true, input_html: {readonly: :true}
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
      f.input :fulfilled
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
    end
  end
end
