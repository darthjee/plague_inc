# frozen_string_literal: true

class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation

  before_action :build_settings, only: [:create]

  private

  def build_settings
  end

  def simulation_params
    binding.pry
    params.require(:simulation)
      .permit(:name, :algorithm)
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
