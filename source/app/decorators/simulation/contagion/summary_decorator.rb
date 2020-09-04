# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Exposes a summary of a contagion simulation
    class SummaryDecorator < Azeroth::Decorator
      expose :status
      expose :stale
      expose :instants, decorator: Instant::SummaryDecorator

      attr_reader :instants

      def initialize(simulation, instants)
        super(simulation)
        @instants = instants
      end

      def stale
        stale?
      end
    end
  end
end
