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

      def random_box
        @random_box ||= RandomBox.new
      end
    end
  end
end
