ActiveAdmin.register_page I18n.t('menu.dashboard') do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
#     columns do
#       column do
#         panel "Resource Cost" do
#           render partial: "bench_cost.html.erb"
#           div class: "popup", "data-popup" : "popup-1" do
#         end
#       end
#       div class: "popup-inner" do
#         div class: "modal-header" do
#           a class: "popup-close", "data-popup-close" : "popup-1", "href" : "#" do "X"
#         end
#       end
#     end
#     div class: "ajax_content_container" do
#       div class: "canvas_conatiner" do
#         canvas id: "popup_one", :style => "width:358;height=89" do
#         end
#       end
#       canvas id: "popup_two", :style => "width:358;height=89" do
#       end
#     end
#   end
#   column do
#     panel "Gross Profit" do
#       render partial: "gross_profit"
#     end
#   end
# end
#
# columns do
#   column do
#     panel "Resource Distribution" do
#       render partial: "bench_distribution"
#     end
#   end
#
#   column do
#     panel "Recent Posts" do
#       render partial: "pipe_line"
#     end
#   end
# end
  end # content


  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    def resource_costs_panel_data
      result = {}
      labels = []
      labels << Date::MONTHNAMES[(Date.today - 2.months).month]
      labels << Date::MONTHNAMES[(Date.today - 1.months).month]
      labels << Date::MONTHNAMES[(Date.today - 0.months).month]
      result['labels'] = labels
      datasets = []
      detail = {}
      bench_costs = []
      bench_costs[0] = AdminUser.total_bench_cost((Date.today - 2.months).at_end_of_month)
      bench_costs[1] = AdminUser.total_bench_cost((Date.today - 1.months).at_end_of_month)
      bench_costs[2] = AdminUser.total_bench_cost((Date.today - 0.months).at_end_of_month)
      data = []
      data << bench_costs[0]
      data << bench_costs[1]
      data << bench_costs[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.bench_cost')
      detail['borderColor'] = '#33A2FF'
      datasets << detail
      detail = {}
      assigned_costs = []
      assigned_costs[0] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 2.months).at_end_of_month)) - currency_as_amount(bench_costs[0]))
      assigned_costs[1] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 1.months).at_end_of_month)) - currency_as_amount(bench_costs[1]))
      assigned_costs[2] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 0.months).at_end_of_month)) - currency_as_amount(bench_costs[2]))
      data = []
      data << assigned_costs[0]
      data << assigned_costs[1]
      data << assigned_costs[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.assigned_cost')
      detail['borderColor'] = '#F29220'
      datasets << detail
      result['datasets'] = datasets
      render json: result
    end

    def gross_profit_panel_data
      result = {}
      labels = []
      labels << Date::MONTHNAMES[(Date.today - 2.months).month]
      labels << Date::MONTHNAMES[(Date.today - 1.months).month]
      labels << Date::MONTHNAMES[(Date.today - 0.months).month]
      result['labels'] = labels
      datasets = []
      detail = {}
      gross_profits = []
      gross_profits[0] = Project.gross_profit((Date.today - 2.months).at_end_of_month)
      gross_profits[1] = Project.gross_profit((Date.today - 1.months).at_end_of_month)
      gross_profits[2] = Project.gross_profit((Date.today - 0.months).at_end_of_month)
      data = []
      data << gross_profits[0]
      data << gross_profits[1]
      data << gross_profits[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.gross_profit')
      detail['borderColor'] = '#33A2FF'
      datasets << detail
      result['datasets'] = datasets
      render json: result
    end

    def resource_distribution_panel_data
      result = {}
      labels = []
      labels << Date::MONTHNAMES[(Date.today - 2.months).month]
      labels << Date::MONTHNAMES[(Date.today - 1.months).month]
      labels << Date::MONTHNAMES[(Date.today - 0.months).month]
      result['labels'] = labels
      datasets = []
      detail = {}
      bench_counts = []
      bench_counts[0] = AdminUser.total_bench_count((Date.today - 2.months).at_end_of_month)
      bench_counts[1] = AdminUser.total_bench_count((Date.today - 1.months).at_end_of_month)
      bench_counts[2] = AdminUser.total_bench_count((Date.today - 0.months).at_end_of_month)
      data = []
      data << bench_counts[0]
      data << bench_counts[1]
      data << bench_counts[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.bench_count')
      detail['borderColor'] = '#33A2FF'
      datasets << detail
      detail = {}
      assigned_counts = []
      assigned_counts[0] = AdminUser.total_resource_count((Date.today - 2.months).at_end_of_month) - bench_counts[0]
      assigned_counts[1] = AdminUser.total_resource_count((Date.today - 1.months).at_end_of_month) - bench_counts[1]
      assigned_counts[2] = AdminUser.total_resource_count((Date.today - 0.months).at_end_of_month) - bench_counts[2]
      data = []
      data << assigned_counts[0]
      data << assigned_counts[1]
      data << assigned_counts[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.assigned_count')
      detail['borderColor'] = '#F29220'
      datasets << detail
      result['datasets'] = datasets
      render json: result
    end

    def pipeline_by_stage_data
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.pipeline_amount')
      detail['borderColor'] = '#F29220'
      pipeline_for_all_statuses = Pipeline.pipeline_for_all_statuses(Date.today.at_end_of_month, 0, 0)
      data = []
      pipeline_for_all_statuses.each do |p|
        labels << p['pipeline_status']
        data << p[Date.today.at_end_of_month.to_s]['total_pipeline']
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def financial_performance_panel_data
      result = {}
      labels = []
      labels << Date::MONTHNAMES[(Date.today - 2.months).month]
      labels << Date::MONTHNAMES[(Date.today - 1.months).month]
      labels << Date::MONTHNAMES[(Date.today - 0.months).month]
      result['labels'] = labels
      payments_received = []
      payments_received << PaymentHeader.payments_received(Date.today - 2.months)
      payments_received << PaymentHeader.payments_received(Date.today - 1.months)
      payments_received << PaymentHeader.payments_received(Date.today - 0.months)
      result['payments_received'] = payments_received
      invoices_raised = []
      invoices_raised << InvoiceHeader.invoices_raised(Date.today - 2.months)
      invoices_raised << InvoiceHeader.invoices_raised(Date.today - 1.months)
      invoices_raised << InvoiceHeader.invoices_raised(Date.today - 0.months)
      result['invoices_raised'] = invoices_raised
      render json: result
    end
  end
end