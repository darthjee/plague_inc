# frozen_string_literal: true

Rails.application.routes.draw do
  get '/' => 'home#show', as: :home

  resources :simulations, only: %i[index create new show] do
    get :clone

    resource :contagion, only: %i[], controller: :contagion do
      get :summary
      post 'process' => 'contagion#run_process'
    end
  end
end
