Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration, only: %i[new edit create update],
                            path: 'users', path_names: { new: 'sign_up' },
                            controller: 'devise/registrations', as: :user_registration
  end

  devise_for :admins

  namespace :admins do
    resource :dashboard, only: :show
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'home#index'
end
