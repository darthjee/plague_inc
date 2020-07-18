# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Initializer
      def self.process(instant)
        new(instant).process
      end

      def process
        instant.status = Instant::PROCESSING

        new_instant.tap do |ins|
          ins.populations = not_healthy.map do |pop|
            Population::Builder.build(
              instant: ins,
              population: pop
            )
          end
          ins.save
          instant.save
        end
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant

      def initialize(instant)
        @instant = instant
      end

      def new_instant
        contagion.instants.build(
          day: instant.day + 1
        )
      end

      def not_healthy
        instant.populations.not_healthy
      end
    end
  end
end
