Rails.application.routes.draw do
  # Health check route (optional, safe to keep)
  get "up" => "rails/health#show", as: :rails_health_check

  # Main application routes
  root "items#to_buy"

  resources :items do
    collection do
      get :to_buy
      get :bought
      get :archived
      get :popular
      post :batch_update_status
      post :create_from_popular
    end
  end
end
