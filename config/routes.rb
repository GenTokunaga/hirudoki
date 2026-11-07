Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    # NOTE: 退会（利用者の削除）は課題の対象外のため、Devise 標準の登録ルートから destroy を除いて定義している
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
