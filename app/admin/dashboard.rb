ActiveAdmin.register_page I18n.t('menu.dashboard') do
  menu if: proc { is_menu_authorized? [I18n.t('role.user')] }, priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do 
    columns do
      column do
        panel "Resource Cost" do 
         render partial: "bench_cost.html.erb"
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
       panel "Pipeline" do
         render partial: "pipe_line"
        end
      end
    end
  column do 
    panel "Financial Performance" do
      render partial:"financial_performance"
    end
  end
  end
  end # content





  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.user')])
    end

    def return_formated_value
     render json:{'format':Money.new(1,"INR").symbol,'en-type':'en-IN'}
    end

    def resource_costs_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
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
      if formatted.upcase == 'NO'
        bench_costs[0] = currency_as_amount(bench_costs[0])
        bench_costs[1] = currency_as_amount(bench_costs[1])
        bench_costs[2] = currency_as_amount(bench_costs[2])
      end
      data = []
      data << bench_costs[0]
      data << bench_costs[1]
      data << bench_costs[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.bench_cost')
      detail['backgroundColor'] = '#6495ED'
      datasets << detail
      detail = {}
      assigned_costs = []
      assigned_costs[0] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 2.months).at_end_of_month)) - currency_as_amount(bench_costs[0]))
      assigned_costs[1] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 1.months).at_end_of_month)) - currency_as_amount(bench_costs[1]))
      assigned_costs[2] = format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - 0.months).at_end_of_month)) - currency_as_amount(bench_costs[2]))
      if formatted.upcase == 'NO'
        assigned_costs[0] = currency_as_amount(assigned_costs[0])
        assigned_costs[1] = currency_as_amount(assigned_costs[1])
        assigned_costs[2] = currency_as_amount(assigned_costs[2])
      end
      data = []
      data << assigned_costs[0]
      data << assigned_costs[1]
      data << assigned_costs[2]
      detail['data'] = data
      detail['label'] = I18n.t('label.assigned_cost')
      detail['backgroundColor'] = '#D2691E'
      datasets << detail
      result['datasets'] = datasets
      render json: result
    end

    def gross_profit_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
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
      if formatted.upcase == 'NO'
        gross_profits[0] = currency_as_amount(gross_profits[0])
        gross_profits[1] = currency_as_amount(gross_profits[1])
        gross_profits[2] = currency_as_amount(gross_profits[2])
      end
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

    def pipeline_by_stage_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
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
        if formatted.upcase == 'NO'
          data << currency_as_amount(p[Date.today.at_end_of_month.to_s]['total_pipeline'])
        else
          data << p[Date.today.at_end_of_month.to_s]['total_pipeline']
        end
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def financial_performance_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      result = {}
      labels = []
      labels << Date::MONTHNAMES[(Date.today - 2.months).month]
      labels << Date::MONTHNAMES[(Date.today - 1.months).month]
      labels << Date::MONTHNAMES[(Date.today - 0.months).month]
      result['labels'] = labels
      payments_received = []
      if formatted.upcase == 'NO'
        payments_received << currency_as_amount(PaymentHeader.payments_received(Date.today - 2.months))
        payments_received << currency_as_amount(PaymentHeader.payments_received(Date.today - 1.months))
        payments_received << currency_as_amount(PaymentHeader.payments_received(Date.today - 0.months))
        result['payments_received'] = payments_received
        invoices_raised = []
        invoices_raised << currency_as_amount(InvoiceHeader.invoices_raised(Date.today - 2.months))
        invoices_raised << currency_as_amount(InvoiceHeader.invoices_raised(Date.today - 1.months))
        invoices_raised << currency_as_amount(InvoiceHeader.invoices_raised(Date.today - 0.months))
        result['invoices_raised'] = invoices_raised
      else
        payments_received << PaymentHeader.payments_received(Date.today - 2.months)
        payments_received << PaymentHeader.payments_received(Date.today - 1.months)
        payments_received << PaymentHeader.payments_received(Date.today - 0.months)
        result['payments_received'] = payments_received
        invoices_raised = []
        invoices_raised << InvoiceHeader.invoices_raised(Date.today - 2.months)
        invoices_raised << InvoiceHeader.invoices_raised(Date.today - 1.months)
        invoices_raised << InvoiceHeader.invoices_raised(Date.today - 0.months)
        result['invoices_raised'] = invoices_raised
      end
      render json: result
    end

    def assigned_costs_by_skill_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.assigned_cost')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#D2691E'
      data = []
      i = 0
      Skill.all.order('name').each do |s|
        labels << s.name
        if formatted.upcase == 'NO'
          data << currency_as_amount(AdminUser.total_resource_cost((Date.today - i.months).at_end_of_month)) - currency_as_amount(AdminUser.bench_cost_for_skill(as_on, s.id))
        else
          data << format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - i.months).at_end_of_month)) - currency_as_amount(AdminUser.bench_cost_for_skill(as_on, s.id)))
        end
        i += 1
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def bench_costs_by_skill_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.bench_cost')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#6495ED'
      data = []
      Skill.all.order('name').each do |s|
        labels << s.name
        if formatted.upcase == 'NO'
          data << currency_as_amount(AdminUser.bench_cost_for_skill(as_on, s.id))
        else
          data << AdminUser.bench_cost_for_skill(as_on, s.id)
        end
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def assigned_costs_by_designation_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.assigned_cost')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#D2691E'
      data = []
      i = 0
      Designation.all.order('name').each do |d|
        labels << d.name
        if formatted.upcase == 'NO'
          data << currency_as_amount(AdminUser.total_resource_cost((Date.today - i.months).at_end_of_month)) - currency_as_amount(AdminUser.bench_cost_for_designation(as_on, d.id))
        else
          data << format_currency(currency_as_amount(AdminUser.total_resource_cost((Date.today - i.months).at_end_of_month)) - currency_as_amount(AdminUser.bench_cost_for_designation(as_on, d.id)))
        end
        i += 1
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def bench_costs_by_designation_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.bench_cost')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#6495ED'
      data = []
      Designation.all.order('name').each do |d|
        labels << d.name
        if formatted.upcase == 'NO'
          data << currency_as_amount(AdminUser.bench_cost_for_designation(as_on, d.id))
        else
          data << AdminUser.bench_cost_for_designation(as_on, d.id)
        end
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def gross_profit_by_business_unit_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.gross_profit')
      detail['borderColor'] = '#F29220'
      data = []
      BusinessUnit.all.order(:name).each do |bu|
        labels << bu.name
        if formatted.upcase == 'NO'
          data << currency_as_amount(Project.gross_profit_for_business_unit(bu.id, as_on))
        else
          data << Project.gross_profit_for_business_unit(bu.id, as_on)
        end
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def gross_profit_versus_indirect_cost_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      labels << I18n.t('label.gross_profit')
      labels << I18n.t('label.indirect_cost')
      result['labels'] = labels
      datasets = []
      detail = {}
      hoverBackgroundColor = []
      hoverBackgroundColor << "#FF6384"
      hoverBackgroundColor << "#36A2EB"
      hoverBackgroundColor << "#FFCE56"
      detail['hoverBackgroundColor'] = hoverBackgroundColor
      backgroundColor = []
      backgroundColor << "#FF6384"
      backgroundColor << "#36A2EB"
      backgroundColor << "#FFCE56"
      detail['backgroundColor'] = backgroundColor
      data = []
      if formatted.upcase == 'NO'
        data << currency_as_amount(Project.gross_profit(as_on))
        data << currency_as_amount(Project.total_indirect_cost_share_for_all_projects(as_on))
      else
        data << Project.gross_profit(as_on)
        data << Project.total_indirect_cost_share_for_all_projects(as_on)
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      render json: result
    end

    def delivery_health_panel_data
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      delivery_health = Project.delivery_health(as_on)
      color_code = []
      project_count = []
      project_ids = []
      delivery_health.keys.each do |key|
        color_code << key
        project_count << delivery_health[key].size
        project_ids << delivery_health[key]
      end
      result['color_code'] = color_code
      result['project_count'] = project_count
      result['project_ids'] = project_ids
      render json: result
    end

    def assigned_counts_by_skill_panel_data
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.assigned_count')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#D2691E'
      data = []
      Skill.all.order('name').each do |s|
        labels << s.name
        data << AdminUser.assigned_count_for_skill(as_on, s.id)
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def bench_counts_by_skill_panel_data
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.bench_count')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#6495ED'
      data = []
      Skill.all.order('name').each do |s|
        labels << s.name
        data << AdminUser.bench_count_for_skill(as_on, s.id)
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def assigned_counts_by_designation_panel_data
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.assigned_count')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#D2691E'
      data = []
      Designation.all.order('name').each do |d|
        labels << d.name
        data << AdminUser.assigned_count_for_designation(as_on, d.id)
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def bench_counts_by_designation_panel_data
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      labels = []
      datasets = []
      detail = {}
      detail['label'] = I18n.t('label.bench_count')
      #detail['borderColor'] = '#F29220'
      detail['backgroundColor'] = '#6495ED'
      data = []
      Designation.all.order('name').each do |d|
        labels << d.name
        data << AdminUser.bench_count_for_designation(as_on, d.id)
      end
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def pipeline_by_business_unit_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      datasets = []
      labels = []
      color_master = ["#FF6384", "#36A2EB", "#FFCE56","#FE6384", "#37B2EB", "#FCCE33"]
      detail = {}
      hoverBackgroundColor = []
      backgroundColor = []
      data = []
      i = 0
      BusinessUnit.all.order('name').each do |bu|
        labels << bu.name
        hoverBackgroundColor << color_master[i]
        backgroundColor << color_master[color_master.size - 1 - i]
        bu_pipeline = Pipeline.pipeline_for_all_statuses(as_on, 0, 0, bu.id)
        bu_pipeline_value = 0
        bu_pipeline.each do |bup|
          bu_pipeline_value += currency_as_amount(bup[as_on]['total_pipeline'])
        end
        if formatted.upcase == 'NO'
          data << currency_as_amount(format_currency(bu_pipeline_value))
        else
          data << format_currency(bu_pipeline_value)
        end
        i += 1
      end
      detail['hoverBackgroundColor'] = hoverBackgroundColor
      detail['backgroundColor'] = backgroundColor
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def pipeline_for_business_unit_panel_data
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      bu_name = params.has_key?(:bu_name) ? params[:bu_name] : nil
      result = {}
      datasets = []
      labels = []
      color_master = ["#FF6384", "#36A2EB", "#FFCE56","#FE6384", "#37B2EB", "#FCCE33"]
      detail = {}
      hoverBackgroundColor = []
      backgroundColor = []
      data = []
      i = 0
      BusinessUnit.where('name = ?', bu_name) .each do |bu|
        labels << bu.name
        hoverBackgroundColor << color_master[i]
        backgroundColor << color_master[color_master.size - 1 - i]
        bu_pipeline = Pipeline.pipeline_for_all_statuses(as_on, 0, 0, bu.id)
        bu_pipeline_value = 0
        bu_pipeline.each do |bup|
          bu_pipeline_value += currency_as_amount(bup[as_on]['total_pipeline'])
        end
        if formatted.upcase == 'NO'
          data << currency_as_amount(format_currency(bu_pipeline_value))
        else
          data << format_currency(bu_pipeline_value)
        end
        i += 1
      end
      detail['hoverBackgroundColor'] = hoverBackgroundColor
      detail['backgroundColor'] = backgroundColor
      detail['data'] = data
      datasets << detail
      result['datasets'] = datasets
      result['labels'] = labels
      render json: result
    end

    def pipeline_by_business_unit_trend
      formatted = params.has_key?(:formatted) ? params[:formatted] : 'NO'
      as_on = params.has_key?(:as_on) ? params[:as_on] : Date.today.to_s
      result = {}
      months = []
      months << (as_on.to_date - 2.months)
      months << (as_on.to_date - 1.months)
      months << (as_on.to_date - 0.months)
      labels = []
      labels << months[0].strftime("%B")
      labels << months[1].strftime("%B")
      labels << months[2].strftime("%B")
      result["labels"] = labels
      color_master = ["#6495ED", "#D2691E", "#FFC200","#FE6384", "#37B2EB", "#FCCE33"]
      datasets = []
      i = 0
      BusinessUnit.all.order('name').each do |bu|
        details = {}
        details["label"] = bu.name
        details["backgroundColor"] = color_master[i]
        data = []
        details["data"] = data
        datasets << details
        months.each do |month|
          bu_pipeline = Pipeline.pipeline_for_all_statuses(month, 0, 0, bu.id)
          bu_pipeline_value = 0
          bu_pipeline.each do |bup|
            bu_pipeline_value += (bup[month.to_s]['total_pipeline'])
          end
          data << bu_pipeline_value
        end
        i += 1
      end
      result["datasets"] = datasets
      render json: result
    end
  end
end