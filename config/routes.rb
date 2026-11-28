Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  devise_for :admins

  root 'daily_menus#index'

  resources :bentos, only: :show
  resources :daily_menus, only: [] do
    resources :orders, only: %i[new create], module: :daily_menus
  end
  resources :orders, only: %i[show edit update] do
    resource :cancellation, only: :create, module: :orders
    resource :review, only: %i[new create], module: :orders
  end
  resource :mypage, only: :show

  namespace :admins do
    resources :bentos, only: %i[index new edit create update destroy]
    resources :delivery_areas, only: %i[index new edit create update destroy]
    resources :daily_menus, only: %i[index new edit create update destroy]
    resources :orders, only: %i[index show update]
    resources :users, only: %i[index show]
    resource :subscription_order_generation, only: %i[new create]
    resource :mypage, only: :show
  end
end
