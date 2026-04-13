Rails.application.routes.draw do
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "homes#index"
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resource :mypage, only: %i[show], controller: :mypage

  concern :favoritable do
    resource :favorite, only: %i[create destroy]
  end

  resources :users, only: %i[index], concerns: [ :favoritable ] do
    collection do
      get :pro_suggestions
    end
  end

  resources :events, concerns: [ :favoritable ] do
    delete "images/:image_id", to: "events#destroy_image", as: :image, on: :member
    collection do
      get :confirm
      post :confirm
    end
  end

  resources :shops, concerns: [ :favoritable ] do
    delete "images/:image_id", to: "shops#destroy_image", as: :image, on: :member
    get :verify_email, on: :member
  end

  resources :notifications, only: %i[index] do
    member do
      patch :read # 既読にして飛ばす用
    end
    collection do
      patch :read_all   # 全部既読
    end
  end

  resource :push_subscription, only: %i[create destroy]

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"

  resource :pro_application, only: %i[new create], controller: :pro_applications
end
