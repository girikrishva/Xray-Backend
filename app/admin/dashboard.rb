ActiveAdmin.register_page I18n.t('menu.dashboard') do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do 
    columns do
      column do
        panel "Bench Distribution" do
          render partial: "bench_distribution"
        end
      end

      column do
        panel "Gross Profit" do
         render partial: "gross_profit.html.erb"
       end
      end
    end
     columns do
      column do
        panel "Recent Posts" do
         render partial: "bench_cost.html.erb"
        end
      end

      column do
       panel "Recent Posts" do
         render partial: "pipe_line.html.erb"
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
