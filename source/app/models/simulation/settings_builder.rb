# frozen_string_literal: true

class Simulation < ApplicationRecord
  class SettingsBuilder
    include Arstotzka

    expose :groups_params,
      full_path: 'simulation.settings.groups',
      json: :params,
      after_each: :permit_group_params,
      default: []

    expose :settings_params,
      full_path: 'simulation.settings',
      json: :params,
      after: :permit_settings_params

    def initialize(simulation, params)
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
      groups_params.each do |group_param|
        simulation.settings.groups.build(group_param)
      end
    end

    def permit_settings_params(params)
      return unless params
      params.permit(*allowed_contagion_params)
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
