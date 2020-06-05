# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Builder
    include Arstotzka

    expose :simulation, after: :build_simulation
    expose :algorithm,  path: :simulation
    expose :settings,   path: :simulation,
                        after: :build_settings
    expose :groups,     path: 'simulation.settings',
                        after_each: :build_group,
                        default: []
    expose :behaviors,  path: 'simulation.settings',
                        after_each: :build_behavior,
                        default: []

    def initialize(params, simulations)
      @params      = params
      @simulations = simulations
    end

    def build
      simulation
    end

    private

    attr_reader :params, :simulations

    def build_simulation(simulation_params)
      simulations.new(
        simulation_params.permit(Simulation::ALLOWED_ATTRIBUTES)
        .merge(settings: settings)
      )
    end

    def build_settings(settings_params)
      return unless algorithm
      return Simulation::Contagion.new unless settings_params

      Simulation::Contagion.new(
        settings_params.permit(
          Simulation::Contagion::ALLOWED_ATTRIBUTES
        ).merge(
          groups: groups,
          behaviors: behaviors
        )
      )
    end

    def build_group(group_params)
      Simulation::Contagion::Group.new(
        group_params.permit(
          Simulation::Contagion::Group::ALLOWED_ATTRIBUTES
        )
      )
    end

    def build_behavior(group_params)
      Simulation::Contagion::Behavior.new(
        group_params.permit(
          Simulation::Contagion::Behavior::ALLOWED_ATTRIBUTES
        )
      )
    end

    def settings_class
      Simulation.const_get(algorithm.capitalize)
    end
  end
end
