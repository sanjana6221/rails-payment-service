Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Payment API routes
  resources :payments, only: [ :create, :show ] do
    member do
      post :cancel
    end
    collection do
      get "user/:user_id", to: "payments#user_payments", as: :user
    end
  end
end
