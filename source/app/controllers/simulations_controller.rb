# frozen_string_literal: true

# Controller for creating, listing and viewing {Simulation}
#
# This controller use basic CRUD methods
class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation, build_with: :build_simulation

  alias clone edit

  private

  def simulation_id
    params.key?(:id) ? params[:id] : params[:simulation_id]
  end

  def build_simulation
    Simulation::Builder.process(params, simulations)
  end
end
