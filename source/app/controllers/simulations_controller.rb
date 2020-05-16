# frozen_string_literal: true

class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation, before_save: :build_settings

  private

  def build_settings
    if simulation.algorithm == 'contagion'
      build_contagion
    end
  end

  def build_contagion
    simulation.build_settings(settings_params)
    params.require(:simulation)[:settings][:groups].each do |group_param|
      simulation.settings.groups.build(group_param.permit(:name))
    end
  end

  def simulation_params
    params.require(:simulation)
          .permit(:name, :algorithm)
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
