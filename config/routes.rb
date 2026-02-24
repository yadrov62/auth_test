Rails.application.routes.draw do
  devise_for :users
  # Root path - tasks index
  root "tasks#index"

  # Task resources with toggle action
  resources :tasks do
    member do
      patch :toggle
    end
  end

  # Placeholder login page (will be replaced by Devise)
  get "login", to: "pages#login", as: :login

  # Health check endpoint
  get "up", to: "rails/health#show", as: :rails_health_check
end

