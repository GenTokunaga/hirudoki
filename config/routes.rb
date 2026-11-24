Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  devise_for :admins

  root 'daily_menus#index'

  resources :bentos, only: :show
  resources :daily_menus, only: [] do
    resources :orders, only: %i[new create], module: :daily_menus
  end
  resources :orders, only: :show

  namespace :admins do
    resources :bentos, only: %i[index new edit create update destroy]
    resources :delivery_areas, only: %i[index new edit create update destroy]
    resources :daily_menus, only: %i[index new edit create update destroy]
  end
end
