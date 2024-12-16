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

  # Cronofy OAuth routes (cleaned up)
  get '/auth/cronofy', to: 'cronofy_auth#connect', as: :auth_cronofy
  get '/auth/cronofy/callback', to: 'cronofy_auth#callback', as: :auth_cronofy_callback
  get '/cronofy/calendars', to: 'cronofy#calendars', as: :cronofy_calendars

  # Omniauth failure route
  get '/auth/failure', to: redirect('/')

  get "/about", to: "pages#about", as: :about
  get "/contact", to: "pages#contact", as: :contact


  root to: 'home#index'

end
