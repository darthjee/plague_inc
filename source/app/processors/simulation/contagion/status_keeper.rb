# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class StatusKeeper
      include ::Processor

      def initialize(simulation, &block)
        @simulation = simulation
        @block      = block
      end

      def process
        simulation.update(status: Simulation::PROCESSING)
        block.call
        simulation.update(status: Simulation::PROCESSED)
      end

      private

      attr_reader :simulation, :block
    end
  end
end
