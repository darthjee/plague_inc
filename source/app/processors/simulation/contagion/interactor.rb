# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PopulationInfector
      def self.process()
        new()
      end

      def process
      end

      private

      def initialize()
      end
    end
  end
end
