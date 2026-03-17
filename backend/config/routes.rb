Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users,
             path: "api/v1/auth",
             path_names: { sign_in: "login", sign_out: "logout" },
             controllers: { sessions: "users/sessions" },
             skip: [:registrations]

  devise_scope :user do
    post "api/v1/auth/signup", to: "users/registrations#create"
  end

  namespace :api do
    namespace :v1 do
      get "me", to: "me#show"
      resources :todos, only: %i[index create update destroy]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
