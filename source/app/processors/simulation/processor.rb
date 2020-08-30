# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    include ::Processor

    def initialize(simulation, options = {})
      @simulation = simulation
      @options    = Processor::Options.new(options)
    end

    def process
      times.times do
        break if simulation.reload.finished?

        settings.process(options)
      end
    end

    private

    attr_reader :simulation, :options
    delegate :settings, to: :simulation
    delegate :times, to: :options
  end
end
