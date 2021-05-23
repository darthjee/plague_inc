# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    class All
      #include ::Processor

      def process
        Simulation::Process.process(next_simulation)
      end

      private

      def next_simulation
        processing_simulation || ready_simulation
      end

      def processing_simulation
        Simulation.order(:updated_at)
          .where("updated_at < ?", Settings.processing_timeout)
          .find_by(status: :processing)
      end

      def ready_simulation
        Simulation.order(:updated_at).find_by(status: %w[processing processed])
      end
    end
  end
end
