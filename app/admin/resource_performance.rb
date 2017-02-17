ActiveAdmin.register AdminUser, as:"Resource Performance" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Resource Performance", parent: I18n.t('menu.reports'), priority: 10
 config.clear_action_items!
config.batch_actions = false

 before_filter :skip_sidebar!
  actions :index
  index  do
     render partial: "resource_performance"
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
  end
end
