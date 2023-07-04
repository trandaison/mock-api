# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :blogs
      resources :login, only: :create
      resource :logout, only: :destroy
      resources :refresh_tokens, only: :create
      resources :users, only: :create
      resource :me, only: :show
    end

    namespace :v2 do
      resources :blogs do
        resources :comments, only: %i[index create]
      end
      resources :comments, only: %i[show update destroy]
      resources :login, only: :create do
        post :google, on: :collection
      end
      resource :logout, only: :destroy
      resources :refresh_tokens, only: :create
      resources :users, only: :create
      resource :me, only: %i[show update]
      resource :reset_password, only: %i[create show update]

      namespace :admin do
        resources :users
      end
    end
  end

  namespace :v2 do
    get 'reset_password/edit', to: 'reset_password#edit'
    put 'reset_password/edit', to: 'reset_password#update'
  end

  root to: redirect('/api-docs')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
