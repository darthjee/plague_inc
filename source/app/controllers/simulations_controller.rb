# frozen_string_literal: true

# Controller for creating, listing and viewing {Simulation}
#
# This controller use basic CRUD methods
class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation,
               build_with: :build_simulation,
               after_save: :trigger_worker,
               paginated: true

  alias clone edit

  private

  def simulations
    Simulation
      .eager_load(:contagion)
      .eager_load(contagion: :groups)
      .eager_load(contagion: :behaviors)
      .eager_load(contagion: :current_instant)
  end

  def simulation_id
    params.key?(:id) ? params[:id] : params[:simulation_id]
  end

  def build_simulation
    Simulation::Builder.process(params, simulations)
  end

  def trigger_worker
    return unless simulation.persisted?

    Simulation::ProcessorWorker.perform_async(simulation.id)
  end
end
