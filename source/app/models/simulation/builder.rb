# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Builder
    include Arstotzka

    expose :simulation, after: :build_simulation
    expose :settings,   path: :simulation,
                        after: :build_settings
    expose :groups,     path: 'simulation.settings',
                        after_each: :build_group,
                        default: []

    def initialize(params, collection)
      @params     = params
      @collection = collection
    end

    def build
      simulation
    end

    private

    attr_reader :params, :collection

    def build_simulation(simulation_params)
      Simulation.new(
        simulation_params.permit(Simulation::ALLOWED_ATTRIBUTES)
        .merge(settings: settings)
      )
    end

    def build_settings(settings_params)
      return unless settings_params

      Simulation::Contagion.new(
        settings_params.permit(
          Simulation::Contagion::ALLOWED_ATTRIBUTES
        ).merge(groups: groups)
      )
    end

    def build_group(group_params)
      Simulation::Contagion::Group.new(
        group_params.permit(:name, :size)
      )
    end
  end
end
