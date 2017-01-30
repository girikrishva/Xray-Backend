ActiveAdmin.register AdminUser, as:"Resource Utilization" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Resource Utilization", parent: I18n.t('menu.reports'), priority: 10
config.batch_actions = false
  actions :index
  index  do
    script :src => javascript_path('resource_utilization.js'), :type => "text/javascript"

    column "Utilization (%)" do |resource|
      data = AdminUser.business_unit_efficiency(resource.business_unit_id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today).strftime("%Y-%m-%d"),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today).strftime("%Y-%m-%d"),false)
      val =  data["data"]["business_unit_utilization_percentage"]
      if val > 0
          div  class:"deployable_resources text_link ",id:"#{resource.business_unit_id}","data-popup-open":"popup-1" do
            val
          end 
        else
          val
        end
    end
    column "Billing Delta" do |resource|
      data = AdminUser.business_unit_efficiency(resource.business_unit_id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today).strftime("%Y-%m-%d"),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today).strftime("%Y-%m-%d"),false)
      div  class:"deployable_resources text_link ",id:"#{resource.business_unit_id}","data-popup-open":"popup-1" do
        data["data"]["business_unit_billing_opportunity_loss"]
      end
    end
    column :business_unit
    column "Resource" do |resource|
      resource.name
    end
    column :designation,  'designations.name' do |resource|
      resource.designation.name
    end

    column 'Employee ID' do |resource|
      resource.associate_no
    end
    column :manager,  'admin_users.name' do |resource|
      resource.manager.name rescue nil
    end
    column :active
    column "Assigned Percentage" do |resource|
      assigned_hours = AssignedResource.assigned_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today))
      working_hours = AssignedResource.working_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today)) 
      val = (assigned_hours / working_hours) * 100 rescue 0 
       if val > 0
          div  class:"assigned_percent text_link ",id:"ap_#{resource.id}","data-popup-open":"popup-1" do
            val
          end 
        else
          val
        end
    end
    column "clocked Percentage" do |resource|
      assigned_hours = AssignedResource.assigned_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today))
      clocked_hours = Timesheet.clocked_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today)) 
      val = (clocked_hours / assigned_hours) * 100 rescue 0
      if val > 0
          div  class:"clocked_percent text_link ",id:"cp_#{resource.id}","data-popup-open":"popup-1" do
            val
          end 
        else
          val
        end
    end

    column "Utilization Percentage" do |resource|
      working_hours = AssignedResource.working_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today)) 
      clocked_hours = Timesheet.clocked_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today)) 
        val = (clocked_hours / working_hours) * 100 rescue 0
        if val > 0
          div  class:"utilization_percent text_link ",id:"up_#{resource.id}","data-popup-open":"popup-1" do
            val
          end 
        else
          val
        end
    end

    column "Billing Delta" do |resource|
      working_hours = AssignedResource.working_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today)) 
      assigned_hours = AssignedResource.assigned_hours(resource.id, (Date.parse(params["q"]["as_on_gteq_date"]) rescue Date.today),( Date.parse(params["q"]["as_on_lteq_date"]) rescue Date.today))
      div  class:"billing_details text_link ",id:"bd_#{resource.id}","data-popup-open":"popup-1" do
      ((working_hours - assigned_hours) * resource.bill_rate).round(0)
      end
    end
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

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.administrator')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_action
      AdminUser.includes [:role, :business_unit, :department, :designation, :admin_user]
    end
  end

  filter :business_unit
  filter :as_on, as: :date_range


end
