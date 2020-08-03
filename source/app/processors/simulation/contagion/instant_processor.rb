# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantProcessor
      def self.process(instant)
        new(instant).process
      end

      def process
        Initializer.process(instant).tap do
          instant.update(status: Instant::PROCESSED)
        end
      end

      private

      attr_reader :instant

      def initialize(instant)
        @instant = instant
      end
    end
  end
end
