# frozen_string_literal: true

Rails.application.routes.draw do
  get '/' => 'home#show', as: :home

  get '/forbidden' => 'static#forbidden', as: :forbidden

  resources :users, only: [:index] do
    collection do
      resources :login, only: [:create] do
        get '/' => :check, on: :collection
      end
      delete '/logoff' => 'login#logoff'
    end
  end

  namespace :admin do
    resources :users
  end
end
