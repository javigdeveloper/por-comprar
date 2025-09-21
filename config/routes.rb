Rails.application.routes.draw do
  # Health check route (optional, safe to keep)
  get "up" => "rails/health#show", as: :rails_health_check

  # Main application routes
  root "items#index"

  resources :items do
    collection do
      get :popular
      get :bought
      get :archived
      post :batch_update_status
    end
  end
end
