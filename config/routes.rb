Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Dashboard route
  get "dashboard", to: "dashboard#index"

  # Home page route
  get "home/index"

  # Tasks routes
  resources :tasks, only: [:index, :show, :edit, :update, :new, :create, :destroy]

  # Appointments routes
  resources :appointments, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  # Families and family members routes
  resources :families do
    resources :family_members, only: [:show, :new, :create, :edit, :update, :destroy]
    post :create_member, on: :member
    delete :remove_member, on: :member
  end

  # Cronofy routes
  get 'auth/cronofy', to: 'cronofy#connect'
  get '/auth/cronofy/callback', to: 'cronofy#callback', as: :auth_cronofy_callback
  get '/cronofy/calendars', to: 'cronofy#calendars', as: 'cronofy_calendars'
  get '/users', to: 'users#index'


  #Pages routes
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact

  # Health check and PWA files
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  root "home#index"
end
