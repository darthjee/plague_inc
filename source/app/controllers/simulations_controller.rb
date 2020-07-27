# frozen_string_literal: true

class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation, build_with: :build_simulation

  private

  def build_simulation
    Simulation::Builder.process(params, simulations)
  end
end
