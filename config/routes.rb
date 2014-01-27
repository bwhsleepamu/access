Access::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  # Resources
  resources :data_dictionary do
    post 'data_attribute_form', :on => :collection
  end
  resources :data_types

  get 'documentations/latest/:type/:id', to: "documentations#latest", as: :latest_documentation
  get 'sources/latest/:type/:id', to: "sources#latest", as: :latest_source

  resources :documentations
  resources :event_dictionary

  post 'events/report', to: "events#report", as: :report

  get 'events/:name/report/subject/:subject_code/ignore_paired', to: "events#report", defaults: {ignore_paired: 1}
  get 'events/:name/report/subject/:subject_code', to: "events#report"
  get 'events/:name/report/subject_group/:subject_group_name/ignore_paired', to: "events#report", defaults: {ignore_paired: 1}
  get 'events/:name/report/subject_group/:subject_group_name', to: "events#report"
  get 'events/:name/report/ignore_paired', to: "events#report", defaults: {ignore_paired: 1}
  get 'events/:name/report', to: "events#report"

  resources :events do
    get ':name', action: :new, on: :new
  end
  resources :sources
  resources :source_types
  resources :subject_groups
  resources :subjects, only: [:index] do
    collection do
      post 'create_list'
      get 'new_list'
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'documentations#index'

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
end
