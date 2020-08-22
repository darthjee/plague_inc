# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    include ::Processor

    def initialize(simulation, times: 1)
      @simulation = simulation
      @times      = times
    end

    def process
      times.times do
        break if simulation.reload.finished?
        settings.process
      end
    end

    private

    attr_reader :simulation, :times
    delegate :settings, to: :simulation
  end
end
