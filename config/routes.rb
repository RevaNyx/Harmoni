Rails.application.routes.draw do
  devise_for :users


  
  # Dashboard route
  get "dashboard", to: "dashboard#index"

  # Home page route
  get "home/index"

  # Tasks routes
  resources :tasks, only: [:index, :show, :edit, :update, :new, :create, :destroy]



  
  # Appointments routes
  resources :appointments, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  
 
  

  # Cronofy routes
  get 'auth/cronofy', to: 'cronofy#connect'
  get '/auth/cronofy/callback', to: 'cronofy#callback', as: :auth_cronofy_callback
  get '/cronofy/calendars', to: 'cronofy#calendars', as: 'cronofy_calendars'

  # Families routes
  resources :families do
    post :create_member, on: :member
    delete :remove_member, on: :member
  end

  # Health check and PWA files
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  root "home#index"
end
