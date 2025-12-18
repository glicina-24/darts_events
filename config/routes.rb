Rails.application.routes.draw do
  root "homes#index"

  devise_for :users

  resources :events, only: %i[index show new create edit update destroy] do
    member do
      delete "images/:image_id", to: "events#destroy_image", as: :image
    end
  end

  resources :shops, only: %i[index show new create edit update destroy] do
    member do
      delete "images/:image_id", to: "shops#destroy_image", as: :image
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
