# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Builder
    include Arstotzka

    expose :simulation, after: :build_simulation

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
      )
    end
  end
end

