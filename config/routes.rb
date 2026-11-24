Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_for :admins
  namespace :admins do
    resources :bentos, only: %i[index new edit create update destroy]
    resources :delivery_areas, only: %i[index new edit create update destroy]
    resources :daily_menus, only: %i[index new edit create update destroy]
  end

  root 'daily_menus#index'
end
