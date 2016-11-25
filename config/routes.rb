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

  match '/admin/api/project_type_description' => 'admin/project_types#description_for_lookup', via: [:get]
  match '/admin/api/vacation_policy_description' => 'admin/vacation_policies#description_for_lookup', via: [:get]
  match '/admin/api/skill_for_staffing' => 'admin/assigned_resources#skill_for_staffing', via: [:get]
  match '/admin/api/designation_for_staffing' => 'admin/assigned_resources#designation_for_staffing', via: [:get]
  match '/admin/api/start_date_for_staffing' => 'admin/assigned_resources#start_date_for_staffing', via: [:get]
  match '/admin/api/end_date_for_staffing' => 'admin/assigned_resources#end_date_for_staffing', via: [:get]
  match '/admin/api/hours_per_day_for_staffing' => 'admin/assigned_resources#hours_per_day_for_staffing', via: [:get]
  match '/admin/api/convert_pipeline', to: 'admin/pipelines#convert_pipeline', via: [:post]
  match '/admin/api/resources_for_skill_designation' => 'admin/resources#resources_for_skill_designation', via: [:get]
end
