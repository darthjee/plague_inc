# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Processor
      def self.process(contagion)
        new(contagion).process
      end

      def process
        Starter.process(contagion)
      end

      private

      attr_reader :contagion

      def initialize(contagion)
        @contagion = contagion
      end
    end
  end
end
