ActiveAdmin.register_page I18n.t('menu.dashboard') do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do 
    columns do
      column do
        panel "Resource Cost" do
         render partial: "bench_cost.html.erb"
         div class:"popup","data-popup": "popup-1" do
      div class:"popup-inner" do
          div class:"modal-header" do 
            a class:"popup-close","data-popup-close":"popup-1","href":"#" do
              "X"
            end
          end
        div class:"ajax_content_container" do 
          div class:"canvas_conatiner" do
         canvas id:"popup_one",:style => "width:358;height=89" do
         end
       end
         # canvas id:"popup_two",:style => "width:358;height=89" do
         # end
        end
      end
    end
        end
      end

      column do
        panel "Gross Profit" do
         render partial: "gross_profit"
       end
      end
    end
     columns do
      column do
        panel "Resource Distribution" do
          render partial: "bench_distribution"
        end
      end

      column do
       panel "Recent Posts" do
         render partial: "pipe_line"
        end
      end
    end
  end

  end # content


  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end
  end
end
