# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Infect
      def self.process(infected, healthy, interactions)
        new(infected, healthy).process
      end

      def process
      end

      private

      attr_reader :infected, :healthy

      def initialize(infected, healthy)
        @infected = infected
        @healthy  = healthy
      end
    end
  end
end
