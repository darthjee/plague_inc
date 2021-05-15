# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Responsible to toggling a simulation as processed/processing
    class StatusKeeper
      include ::Processor

      def initialize(simulation, &block)
        @simulation = simulation
        @block      = block
      end

      def process
        simulation.update(status: Simulation::PROCESSING)
        block.call
        simulation.reload.update(status: status)
      end

      private

      attr_reader :simulation, :block
      delegate :contagion, to: :simulation
      delegate :instants, to: :contagion
      delegate :populations, to: :ready_instant

      def status
        finished? ? FINISHED : PROCESSED
      end

      def finished?
        return false if instants.processing.any?

        !infected?
      end

      def ready_instant
        instants.ready.last
      end

      def infected?
        populations.infected.with_population.any?
      end
    end
  end
end
