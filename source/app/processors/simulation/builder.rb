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
      groups
      behaviors
      settings
      simulation
    end

    private

    attr_reader :params, :simulations

    def build_simulation(simulation_params)
      build_object(simulation_params, simulations, Simulation)
    end

    def build_settings(settings_params)
      return unless algorithm
      return simulation.build_contagion unless settings_params

      simulation.build_contagion(
        settings_params.permit(Simulation::Contagion::ALLOWED_ATTRIBUTES)
      )
    end

    def build_group(group_params)
      group_behavior = behaviors.find do |behavior|
        behavior.reference == group_params[:behavior]
      end

      build_object(
        group_params, settings.groups,
        Simulation::Contagion::Group,
        behavior: group_behavior
      )
    end

    def build_behavior(behavior_params)
      build_object(
        behavior_params, settings.behaviors, Simulation::Contagion::Behavior,
        contagion: settings
      )
    end

    def build_object(params, collection, klass, **attributes)
      collection.build(
        params.permit(klass::ALLOWED_ATTRIBUTES)
        .merge(**attributes)
      )
    end

    def settings_class
      Simulation.const_get(algorithm.capitalize)
    end
  end
end
