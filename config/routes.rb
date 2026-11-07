Rails.application.routes.draw do
  # 利用者：ログイン・ログアウト（/users/sign_in）
  # 退会（利用者の削除）は対象外のため、登録系は destroy を除いて個別に定義する。
  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'users/sign_up', to: 'devise/registrations#new', as: :new_user_registration
    post 'users', to: 'devise/registrations#create', as: :user_registration
    get 'users/edit', to: 'devise/registrations#edit', as: :edit_user_registration
    patch 'users', to: 'devise/registrations#update'
    put 'users', to: 'devise/registrations#update'
  end

  # 管理者：ログイン・ログアウトのみ（/admin/sign_in）。アカウントはシードで作成する。
  devise_for :admins, path: 'admin'

  namespace :admin do
    root 'dashboard#index'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'home#index'
end
