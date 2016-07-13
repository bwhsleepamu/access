# frozen_string_literal: true

Rails.application.routes.draw do
  # get 'account(/:auth_token)/profile' => 'account#profile'

  get '/auth/failure', to: 'authentications#failure'
  post '/auth/ldap/callback', to: 'authentications#create'
  get '/auth/ldap', to: 'authentications#passthru'

  devise_for :users, path_names: { sign_up: 'register', sign_in: 'login' }, path: ''


  # Resources
  resources :users
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

  root 'documentations#index'
end
