# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Builder
    include Arstotzka

    expose :simulation, cached: true, after: :build_simulation
    expose :settings, path: :simulation, cached: true, after: :build_settings
    expose :groups, path: 'simulation.settings', cached: true, after_each: :build_group

    def initialize(params, collection)
      @json       = params
      @collection = collection
    end

    def build
      simulation
    end

    private

    attr_reader :json, :collection

    def build_simulation(simulation_params)
      Simulation.new(
        simulation_params.permit(:name, :algorithm)
        .merge(settings: settings)
      )
    end

    def build_settings(settings_params)
      Simulation::Contagion.new(
        settings_params.permit(*%i[
          lethality
          days_till_recovery
          days_till_sympthoms
          days_till_start_death
        ])
          .merge(groups: groups)
      )
    end

    def build_group(group_params)
      Simulation::Contagion::Group.new(
        group_params.permit(:name, :size)
      )
    end
  end
end
