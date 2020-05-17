# frozen_string_literal: true

class Simulation < ApplicationRecord
  class SettingsBuilder
    include Arstotzka

    expose :groups,
           path: 'simulation.settings',
           json: :params,
           after_each: :permit_group_params,
           default: []

    def initialize(simulation, params)
      puts params.class
      @simulation = simulation
      @params = params
    end

    def build
      build_contagion if simulation.algorithm == 'contagion'
    end

    private

    attr_reader :simulation, :params

    def build_contagion
      simulation.build_settings(settings_params)
      groups.each do |group_param|
        simulation.settings.groups.build(group_param)
      end
    end

    def groups_params
      params.require(:simulation)[:settings][:groups]
    end

    def settings_params
      params.require(:simulation)
            .permit(settings: allowed_contagion_params)[:settings]
    end

    def allowed_contagion_params
      %i[
        lethality
        days_till_recovery
        days_till_sympthoms
        days_till_start_death
      ]
    end

    def permit_group_params(group_params)
      group_params.permit(:name)
    end
  end
end
