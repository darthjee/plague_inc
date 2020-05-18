# frozen_string_literal: true

class SimulationsController < ApplicationController
  include OnePageApplication

  protect_from_forgery except: [:create]

  resource_for :simulation, before_save: :build_settings

  private

  def build_settings
    Simulation::SettingsBuilder
      .new(simulation, params)
      .build
  end
end
