# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Initializer
      def self.process(instant)
        new(instant).process
      end

      def process
        instant.status = Instant::PROCESSING
        instant.save
        new_instant
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant

      def initialize(instant)
        @instant = instant
      end

      def new_instant
        contagion.instants.create(
          day: instant.day + 1
        )
      end
    end
  end
end
