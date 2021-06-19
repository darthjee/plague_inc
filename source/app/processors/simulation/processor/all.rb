# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Processor
    class All
      include ::Processor

      attr_reader :simulation_id

      def initialize(simulation_id=nil)
        @simulation_id = simulation_id
      end

      def process
        1000.times do
          try_process
        end
      end

      private

      def try_process
        simulation = next_simulation
        if simulation
          reset_delay
          Simulation::Processor.process(simulation)
        else
          wait
          increase_delay
        end
      end

      def next_simulation
        simulation_from_id || processing_simulation || ready_simulation
      end


      def simulation_from_id
        return unless simulation_id
        @simulation ||= Simulation.find(simulation_id)
      end

      def processing_simulation
        Simulation
          .order(:updated_at)
          .where('updated_at < ?', Settings.processing_timeout.ago)
          .find_by(status: :processing)
      end

      def ready_simulation
        Simulation
          .order(:created_at)
          .find_by(status: %w[created processed])
      end

      def delay
        @delay ||= 30.seconds
      end

      def reset_delay
        @delay = nil
      end

      def increase_delay
        @delay = delay * 2
      end

      def wait
        puts "Waiting #{delay / 60.0} minutes"
        sleep(delay)
      end
    end
  end
end
