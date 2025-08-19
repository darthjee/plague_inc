# frozen_string_literal: true

Rails.application.routes.draw do
  get '/' => 'home#show', as: :home
  get '/.json' => 'home#show'

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

  resources :tags, only: %i[index]

  resources :simulations, only: %i[index create new show] do
    get :clone

    resource :contagion, only: %i[], controller: :contagion do
      get :summary
      post 'process' => 'contagion#run_process'
    end
  end
end
