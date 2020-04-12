# frozen_string_literal: true

class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation
end
