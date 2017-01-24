ActiveAdmin.register Project, as: "DeliveryHealth" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "DeliveryHealth", parent: I18n.t('menu.reports'), priority: 10
config.batch_actions = false
  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :project_status_id, :start_date, :end_date, :booking_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :pipeline_id, :updated_at, :updated_by, :ip_address
  config.clear_action_items!
  index do 
    script :src => javascript_path('delivery_health.js'), :type => "text/javascript"
    # column :id
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column I18n.t('label.project'), :name
    if @@show_project_detail
      column I18n.t('label.start'), :start_date
      column I18n.t('label.end'), :end_date
      column I18n.t('label.type'), :project_type_code, sortable: 'project_type_codes.name' do |resource|
        resource.project_type_code.name
      end
    end

    column "Project Helth" do |element|
      color = element.delivery_health(Date.today.strftime("%Y-%m-%d"))["delivery_health"]
     div :style => "text-align: center;background-color: #{color};",class: "hide_it #{color}"  do 
      color
      end
    end
  
    if @@financial_detail
    # column I18n.t('label.invoiced_amount'), :invoiced_amount do |element|
    #   div :style => "text-align: right;" do
    #     number_with_precision element.invoiced_amount, precision: 0, delimiter: ','
    #   end
    # end
     column "Missed Delivery" do |element|
      div class:"missed_delivery text_link",:style => "text-align: right;",id:"md_#{element.id}","data-popup-open":"popup-1" do
        element.missed_delivery(nil,nil)["count"]
      end
    end
     column "Missed Invoicing" do |element|
      div class:"missed_invoicing text_link",:style => "text-align: right;" ,id:"mi_#{element.id}","data-popup-open":"popup-1"do
        element.missed_invoicing(nil,nil)["count"]
      end
    end
    column "Missed Payment" do |element|
      div class:"missed_payments text_link",:style => "text-align: right;",id:"mp_#{element.id}","data-popup-open":"popup-1" do
        element.missed_payments(nil,nil)["count"]
      end
    end

       column "Project Contribution Status" do |element|
      div :style => "text-align: right;" do
        element.contribution(Date.today.strftime("%Y-%m-%d"))["contribution"] < 0 ? "-ve" : "+ve"
      end
    end
     column "Gross Profit Status" do |element|
      div :style => "text-align: right;" do
        element.gross_profit(Date.today.strftime("%Y-%m-%d"))["gross_profit"] < 0 ? "-ve" : "+ve"
      end
    end
    column "Overdue Invoicing" do |element|
      div :style => "text-align: right;" do
        element.missed_invoicing(nil,nil)["total_uninvoiced"]
      end
    end
    column "Overdue Payment" do |element|
      div :style => "text-align: right;" do
        element.missed_payments(nil,nil)["total_unpaid"]
      end
    end
    column "Project Contribution" do |element|
      div class:"contribution text_link",id:"contribution_#{element.id}","data-popup-open":"popup-1",:style => "text-align: right;" do
        element.contribution(Date.today.strftime("%Y-%m-%d"))["contribution"].abs
      end
    end
     column "Gross Profit" do |element|
      div class:"gross_profit text_link",id:"gp_#{element.id}","data-popup-open":"popup-1",:style => "text-align: right;" do
        element.gross_profit(Date.today.strftime("%Y-%m-%d"))["gross_profit"].abs
      end
    end
  end
  column :delivery_manager
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

  filter :client, collection: proc {Client.ordered_lookup.map{|a| [a.client_name, a.id]}}
  filter :name, label: I18n.t('label.project')
  filter :comments, label: "Project Details",collection:["Show","Hide"],as: :select
  filter :project_type_code, label: I18n.t('label.type'), collection:
                               proc { Lookup.lookups_for_name(I18n.t('models.project_code_types')) }, if: proc { @@show_project_detail}
  filter :project_status, label: I18n.t('label.status'), if: proc { @@show_project_detail}
  filter :delivery_manager
  filter :booking_value, label: "Financial Details",collection:["Show","Hide"],as: :select
  filter :project_health,collection:["Red","Orange","Yellow", "Green"],as: :select
  filter :contribution_status,collection:["+ve","-ve"],as: :select
  filter :gross_profit_status,collection:["+ve","-ve"],as: :select
  
  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.manager')])
    end
    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }
    def scoped_collection
      if params["project_name"].present?
      params[:q] = {}
      params[:q][:name_equals]= params["project_name"]
      params.delete(:project_name) 
      end
      @@show_project_detail = (params[:q][:comments_eq] == "Show" rescue false) ? true : false
      params[:q].delete(:comments_eq) rescue nil
      @@financial_detail = (params[:q][:booking_value_eq] == "Show" rescue false) ? true : false
      params[:q].delete(:booking_value_eq) rescue nil
      @projects = Project.includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
      if (params[:q])
        
        if  params[:q][:project_health].present?
          proj  = []
        @projects.each do |x|
          proj << x.id if params[:q][:project_health] == x.delivery_health(Date.today.strftime("%Y-%m-%d"))["delivery_health"].capitalize
        end
        params[:q].delete(:project_health)
        @projects = Project.where(id:proj).includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
        end
         if  params[:q][:contribution_status].present?
          proj  = []
        @projects.each do |x|
          proj << x.id if params[:q][:contribution_status] == (x.contribution(Date.today.strftime("%Y-%m-%d"))["contribution"] < 0 ? "-ve" : "+ve")
        end
        params[:q].delete(:contribution_status)
        @projects = Project.where(id:proj).includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
        end
         if  params[:q][:gross_profit_status].present?
          proj  = []
        @projects.each do |x|
          proj << x.id if params[:q][:gross_profit_status] == (x.gross_profit(Date.today.strftime("%Y-%m-%d"))["gross_profit"] < 0 ? "-ve" : "+ve")
        end
        params[:q].delete(:gross_profit_status)
        @projects = Project.where(id:proj).includes [:business_unit, :client, :project_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager, :pipeline]
        end
        @projects 
      else
        @projects 
      end
    end
  end
end
