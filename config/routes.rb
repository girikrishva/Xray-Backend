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
end
