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
               paginated: true,
               per_page: 10

  alias clone edit

  private

  def simulations
    @simulations ||= filter.apply(loaded_simulations)
  end

  def filter
    Simulation::Filter.new(filter_hash)
  end

  def filter_hash
    params[:filter]&.permit(:name, :status)
  end

  def loaded_simulations
    Simulation
      .eager_load(:contagion, :tags)
      .eager_load(contagion: :groups)
      .eager_load(contagion: :behaviors)
      .eager_load(contagion: :current_instant)
      .eager_load(contagion: { groups: :behavior })
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
