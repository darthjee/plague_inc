# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class SummaryDecorator < Azeroth::Decorator
      expose :status
      expose :instants, decorator: Instant::SummaryDecorator

      def initialize(simulation, instants)
        super(simulation)
        @instants = instants
      end

      attr_reader :instants
    end
  end
end
