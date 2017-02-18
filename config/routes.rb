Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  match '/admin/api/restore_role', to: 'admin/roles#restore', via: [:post]
  match '/admin/api/restore_admin_user', to: 'admin/admin_users#restore', via: [:post]
  match '/admin/api/restore_admin_users_audit', to: 'admin/admin_users_audits#restore', via: [:post]
  match '/admin/api/restore_lookup_type', to: 'admin/lookup_types#restore', via: [:post]
  match '/admin/api/restore_lookup', to: 'admin/lookups#restore', via: [:post]
  match '/admin/api/restore_vacation_policy', to: 'admin/vacation_policies#restore', via: [:post]
  match '/admin/api/restore_holiday_calendar', to: 'admin/holiday_calendars#restore', via: [:post]
  match '/admin/api/restore_project_type', to: 'admin/project_types#restore', via: [:post]
  match '/admin/api/restore_resource', to: 'admin/resources#restore', via: [:post]
  match '/admin/api/restore_overhead', to: 'admin/overheads#restore', via: [:post]
  match '/admin/api/restore_client', to: 'admin/clients#restore', via: [:post]
  match '/admin/api/restore_vacation', to: 'admin/vacations#restore', via: [:post]
  match '/admin/api/restore_timesheet', to: 'admin/timesheets#restore', via: [:post]
  match '/admin/api/restore_project', to: 'admin/projects#restore', via: [:post]
  match '/admin/api/restore_assigned_resource', to: 'admin/assigned_resources#restore', via: [:post]
  match '/admin/api/restore_project_overhead', to: 'admin/project_overheads#restore', via: [:post]
  match '/admin/api/restore_delivery_milestone', to: 'admin/delivery_milestones#restore', via: [:post]
  match '/admin/api/restore_delivery_invoicing_milestone', to: 'admin/delivery_invoicing_milestones#restore', via: [:post]
  match '/admin/api/restore_invoicing_milestone', to: 'admin/invoicing_milestones#restore', via: [:post]
  match '/admin/api/restore_invoicing_delivery_milestone', to: 'admin/invoicing_delivery_milestones#restore', via: [:post]
  match '/admin/api/restore_pipeline', to: 'admin/pipelines#restore', via: [:post]
  match '/admin/api/restore_staffing_requirement', to: 'admin/staffing_requirements#restore', via: [:post]
  match '/admin/api/restore_invoice_header', to: 'admin/invoice_headers#restore', via: [:post]
  match '/admin/api/restore_invoice_line', to: 'admin/invoice_lines#restore', via: [:post]
  match '/admin/api/restore_payment_header', to: 'admin/payment_headers#restore', via: [:post]
  match '/admin/api/restore_payment_line', to: 'admin/payment_lines#restore', via: [:post]

  match '/admin/api/project_type_description' => 'admin/project_types#description_for_lookup', via: [:get]
  match '/admin/api/vacation_policy_description' => 'admin/vacation_policies#description_for_lookup', via: [:get]
  match '/admin/api/skill_for_staffing' => 'admin/assigned_resources#skill_for_staffing', via: [:get]
  match '/admin/api/designation_for_staffing' => 'admin/assigned_resources#designation_for_staffing', via: [:get]
  match '/admin/api/start_date_for_staffing' => 'admin/assigned_resources#start_date_for_staffing', via: [:get]
  match '/admin/api/end_date_for_staffing' => 'admin/assigned_resources#end_date_for_staffing', via: [:get]
  match '/admin/api/hours_per_day_for_staffing' => 'admin/assigned_resources#hours_per_day_for_staffing', via: [:get]
  match '/admin/api/convert_pipeline', to: 'admin/pipelines#convert_pipeline', via: [:post]
  match '/admin/api/resources_for_staffing' => 'admin/resources#resources_for_staffing', via: [:get]
  match '/admin/api/resource_details' => 'admin/resources#resource_details', via: [:get]
  match '/admin/api/staffing_fulfilled', to: 'admin/assigned_resources#staffing_fulfilled', via: [:post]
  match '/admin/api/invoicing_milestones_for_project' => 'admin/invoicing_milestones#invoicing_milestones_for_project', via: [:get]
  match '/admin/api/invoicing_milestone' => 'admin/invoice_lines#invoicing_milestone', via: [:get]
  match '/admin/api/invoicing_milestone_uninvoiced' => 'admin/invoice_lines#invoicing_milestone_uninvoiced', via: [:get]
  match '/admin/api/invoice_adder_type' => 'admin/invoice_lines#invoice_adder_type', via: [:get]
  match '/admin/api/invoice_line_narrative' => 'admin/invoice_lines#invoice_line_narrative', via: [:get]
  match '/admin/api/unpaid_amount' => 'admin/invoice_lines#unpaid_amount', via: [:get]
  match '/admin/api/invoice_lines_for_header' => 'admin/invoice_lines#invoice_lines_for_header', via: [:get]
  match '/admin/api/approve_vacation', to: 'admin/vacations#approve_vacation', via: [:post]
  match '/admin/api/reject_vacation', to: 'admin/vacations#reject_vacation', via: [:post]
  match '/admin/api/cancel_vacation', to: 'admin/vacations#cancel_vacation', via: [:post]
  match '/admin/api/make_vacation_pending', to: 'admin/vacations#make_vacation_pending', via: [:post]
  match '/admin/api/approve_timesheet', to: 'admin/timesheets#approve_timesheet', via: [:post]
  match '/admin/api/reject_timesheet', to: 'admin/timesheets#reject_timesheet', via: [:post]
  match '/admin/api/cancel_timesheet', to: 'admin/timesheets#cancel_timesheet', via: [:post]
  match '/admin/api/make_timesheet_pending', to: 'admin/timesheets#make_timesheet_pending', via: [:post]
  match '/admin/api/clients_for_business_unit' => 'admin/pipelines#clients_for_business_unit', via: [:get]

  # Reports APIs.
  match '/admin/api/admin_user_details' => 'admin/admin_users#admin_user_details', via: [:get]
  match '/admin/api/overall_delivery_health' => 'admin/projects#overall_delivery_health', via: [:get]
  match '/admin/api/project_details' => 'admin/projects#project_details', via: [:get]
  match '/admin/api/missed_delivery' => 'admin/projects#missed_delivery', via: [:get]
  match '/admin/api/missed_invoicing' => 'admin/projects#missed_invoicing', via: [:get]
  match '/admin/api/missed_payments' => 'admin/projects#missed_payments', via: [:get]
  match '/admin/api/direct_resource_cost' => 'admin/projects#direct_resource_cost', via: [:get]
  match '/admin/api/direct_overhead_cost' => 'admin/projects#direct_overhead_cost', via: [:get]
  match '/admin/api/total_direct_cost' => 'admin/projects#total_direct_cost', via: [:get]
  match '/admin/api/total_indirect_resource_cost_share' => 'admin/projects#total_indirect_resource_cost_share', via: [:get]
  match '/admin/api/total_indirect_overhead_cost_share' => 'admin/projects#total_indirect_overhead_cost_share', via: [:get]
  match '/admin/api/total_indirect_cost_share' => 'admin/projects#total_indirect_cost_share', via: [:get]
  match '/admin/api/total_cost' => 'admin/projects#total_cost', via: [:get]
  match '/admin/api/total_revenue' => 'admin/projects#total_revenue', via: [:get]
  match '/admin/api/contribution' => 'admin/projects#contribution', via: [:get]
  match '/admin/api/contribution_details' => 'admin/projects#contribution_details', via: [:get]
  match '/admin/api/gross_profit' => 'admin/projects#gross_profit', via: [:get]
  match '/admin/api/gross_profit_details' => 'admin/projects#gross_profit_details', via: [:get]
  match '/admin/api/delivery_health' => 'admin/projects#delivery_health', via: [:get]
  match '/admin/api/pipeline_for_status' => 'admin/pipelines#pipeline_for_status', via: [:get]
  match '/admin/api/pipeline_for_all_statuses' => 'admin/pipelines#pipeline_for_all_statuses', via: [:get]
  match '/admin/api/resource_distribution_combos' => 'admin/resources#resource_distribution_combos', via: [:get]
  match '/admin/api/resource_details' => 'admin/resources#resource_details', via: [:get]
  match '/admin/api/staffing_forecast' => 'admin/staffing_requirements#staffing_forecast', via: [:get]
  match '/admin/api/staffing_required' => 'admin/staffing_requirements#staffing_required', via: [:get]
  match '/admin/api/staffing_fulfilled' => 'admin/staffing_requirements#staffing_fulfilled', via: [:get]
  match '/admin/api/deployable_resources' => 'admin/staffing_requirements#deployable_resources', via: [:get]
  match '/admin/api/resource_efficiency' => 'admin/admin_users#resource_efficiency', via: [:get]
  match '/admin/api/business_unit_efficiency' => 'admin/admin_users#business_unit_efficiency', via: [:get]
  match '/admin/api/overall_efficiency' => 'admin/admin_users#overall_efficiency', via: [:get]
  match '/admin/api/active_users_outflow' => 'admin/admin_users_audits#active_users_outflow', via: [:get]
  match '/admin/api/inactive_users_outflow' => 'admin/admin_users_audits#inactive_users_outflow', via: [:get]
  match '/admin/api/all_users_outflow' => 'admin/admin_users_audits#all_users_outflow', via: [:get]
  match '/admin/api/active_users_inflow' => 'admin/admin_users_audits#active_users_inflow', via: [:get]
  match '/admin/api/inactive_users_inflow' => 'admin/admin_users_audits#inactive_users_inflow', via: [:get]
  match '/admin/api/all_users_inflow' => 'admin/admin_users_audits#all_users_inflow', via: [:get]
  match '/admin/api/active_users_netflow' => 'admin/admin_users_audits#active_users_netflow', via: [:get]
  match '/admin/api/inactive_users_netflow' => 'admin/admin_users_audits#inactive_users_netflow', via: [:get]
  match '/admin/api/all_users_netflow' => 'admin/admin_users_audits#all_users_netflow', via: [:get]
  match '/admin/api/delivery_milestones' => 'admin/delivery_milestones#delivery_milestones', via: [:get]
  match '/admin/api/delivery_milestone_details' => 'admin/delivery_milestones#delivery_milestone_details', via: [:get]
  match '/admin/api/invoicing_milestones' => 'admin/invoicing_milestones#invoicing_milestones', via: [:get]
  match '/admin/api/invoicing_milestone_details' => 'admin/invoicing_milestones#invoicing_milestone_details', via: [:get]
  match '/admin/api/collection_milestones' => 'admin/invoice_headers#collection_milestones', via: [:get]
  match '/admin/api/collection_milestone_details' => 'admin/invoice_headers#collection_milestone_details', via: [:get]
  match '/admin/api/reconciliation_milestones' => 'admin/payment_headers#reconciliation_milestones', via: [:get]
  match '/admin/api/reconciliation_milestone_details' => 'admin/payment_headers#reconciliation_milestone_details', via: [:get]
end
