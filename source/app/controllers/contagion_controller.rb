# frozen_string_literal: true

class ContagionController < ApplicationController
  def summary
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

  def instants
    contagion.instants.limit(Settings.contagion_instants_pagination)
  end
end

