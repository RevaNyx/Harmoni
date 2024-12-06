Rails.application.routes.draw do
  devise_for :users
  
  # Dashboard route
  get "dashboard", to: "dashboard#index"

  # Home page route
  get "home/index"

  # Tasks routes
  resources :tasks

  # Families routes
  resources :families do
    # Route to handle adding family members
    post :create_member, on: :member
  end

  # Health check and PWA files
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  root "home#index"
end
