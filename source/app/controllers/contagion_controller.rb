# frozen_string_literal: true

class ContagionController < ApplicationController
  def summary
    render json: decoratad_simulation
  end

  def run_process
    @instants = process_simulation

    render json: decoratad_simulation
  end

  private

  delegate :contagion, to: :simulation

  def decoratad_simulation
    Simulation::Contagion::SummaryDecorator.new(
      simulation, instants
    )
  end

  def simulation
    @simulation ||= Simulation.find(simulation_id)
  end

  def simulation_id
    params.require(:simulation_id)
  end

  def process_simulation
    Simulation::Processor
      .process(simulation, processing_options)
      .map(&:reload)
  end

  def instants
    @instants ||= scoped_instants.limit(limit)
  end

  def processing_options
    params.fetch(:options, {})
  end

  def scoped_instants
    return contagion.instants unless pagination_last_instant_id

    contagion.instants.where('id > ?', pagination_last_instant_id)
  end

  def pagination_last_instant_id
    @pagination_last_instant_id ||= params.dig(:pagination, :last_instant_id)
  end

  def limit
    params.dig(:pagination, :limit) ||
      Settings.contagion_instants_pagination
  end
end
