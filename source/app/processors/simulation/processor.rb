# frozen_string_literal: true

class Simulation < ApplicationRecord
  # @author darthjee
  #
  # Process a simulation
  class Processor
    include ::Processor

    # @param simulation [Simulation] simulation to be
    #   processed
    # @param options [Hash] processing options
    # @option options times [Integer] Number of instants
    #   to be generated / processed
    # @option options interaction_block_size [Integer]
    #   blocks of interactions to be processed between
    #   each save
    #
    # @see Simulation::Processor::Options
    def initialize(simulation, options = {})
      @simulation = simulation
      @options    = Processor::Options.new(options)
    end

    def process
      times.to_i.times.map do
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
