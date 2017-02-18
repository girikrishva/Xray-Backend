ActiveAdmin.register StaffingRequirement, as:"Resource Forecast" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Resource Forecast", parent: I18n.t('menu.reports'), priority: 10
config.batch_actions = false
 before_filter :skip_sidebar!

  actions :index
  index do
    script :src => javascript_path('resource_forecast.js'), :type => "text/javascript"
      render partial: "resource_forecast"
       div class:"popup","data-popup": "popup-1" do
      div class:"popup-inner" do
          div class:"modal-header" do 
            a class:"popup-close","data-popup-close":"popup-1","href":"#" do
              "X"
            end
          end
        div class:"ajax_content_container" do 
          div class:"ajax_content" do 
          end
        end
      end
    end
    #   div class:"popup","data-popup": "popup-1" do
    #   div class:"popup-inner",style:"overflow : auto;" do
    #     span class:"ajax_content" do 
    #     end
    #       a class:"popup-close","data-popup-close":"popup-1","href":"#" do
    #         "Close"
    #       end
    #   end
    # end
  end


end
