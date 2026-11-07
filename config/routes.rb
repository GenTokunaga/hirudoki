Rails.application.routes.draw do
  # NOTE: 退会（利用者の削除）は課題の対象外のため、登録系は destroy を除いて個別に定義している
  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'users/sign_up', to: 'devise/registrations#new', as: :new_user_registration
    post 'users', to: 'devise/registrations#create', as: :user_registration
    get 'users/edit', to: 'devise/registrations#edit', as: :edit_user_registration
    patch 'users', to: 'devise/registrations#update'
    put 'users', to: 'devise/registrations#update'
  end

  devise_for :admins, path: 'admin'

  # NOTE: URL は Devise の管理者ログイン（/admin/sign_in）とそろえて /admin にしている
  namespace :admins, path: 'admin' do
    root 'dashboard#index'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'home#index'
end
