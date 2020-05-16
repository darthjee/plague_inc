# frozen_string_literal: true

class Simulation < ApplicationRecord
  class BuildSettings
    def initialize(simulation, params)
      @simulation = simulation
      @params = params
    end

    def build
      if simulation.algorithm == 'contagion'
        build_contagion
      end
    end

    private

    attr_reader :simulation, :params

    def build_contagion
      simulation.build_settings(settings_params)
      params.require(:simulation)[:settings][:groups].each do |group_param|
        simulation.settings.groups.build(group_param.permit(:name))
      end
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


  end
end
