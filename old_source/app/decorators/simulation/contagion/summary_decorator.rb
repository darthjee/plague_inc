# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Exposes a summary of a contagion simulation
    class SummaryDecorator < Azeroth::Decorator
      expose :status
      expose :processable?, as: :processable
      expose :processable_in
      expose :instants, decorator: Instant::SummaryDecorator
      expose :instants_total

      attr_reader :instants

      def initialize(simulation, instants)
        super(simulation)
        @instants = instants
      end

      def instants_total
        object.contagion.instants.count
      end
    end
  end
end
