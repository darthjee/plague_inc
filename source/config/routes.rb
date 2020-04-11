# frozen_string_literal: true

Rails.application.routes.draw do
  get '/' => 'home#show', as: :home
end
