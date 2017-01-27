ActiveAdmin.register Pipeline , as: "Pipeline Forecast" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Pipeline Forecast", parent: I18n.t('menu.reports'), priority: 10

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

  permit_params :business_unit_id, :client_id, :name, :project_type_code_id, :pipeline_status_id, :expected_start, :expected_end, :expected_value, :comments, :sales_person_id, :estimator_id, :engagement_manager_id, :delivery_manager_id, :updated_at, :updated_by, :ip_address
  config.filters = false

  config.clear_action_items!

  index  do
    script :src => javascript_path('pipeline_forecast.js'), :type => "text/javascript"
    column :client, sortable: 'clients.name' do |resource|
      resource.client.name
    end
    column I18n.t('label.project'), :name
    column I18n.t('label.status'), :pipeline_status, sortable: 'pipeline_statuses.name' do |resource|
      resource.pipeline_status.name
    end
    ((Date.today-6.months)..(Date.today+6.months)).to_a.collect{|x| x.strftime("%Y-%m")}.uniq.each do |x|
      column "#{x}" do |resource|
          if resource.expected_start.strftime("%Y-%m").include?(x)
            div class:"text_link","data-popup-open":"popup-1" do
              number_to_currency(resource.expected_value)
            end
          else
            number_to_currency(0)
          end
      end
    end
    column :expected_start do |x|
      x.expected_start.strftime("%Y-%m-%d")
    end
    column :pipeline_status_id do |x|
      x.pipeline_status_id
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
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

    def scoped_collection
      Pipeline.includes [:business_unit, :client, :pipeline_status, :project_type_code, :sales_person, :estimator, :engagement_manager, :delivery_manager]
    end
  end
end
