# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Processor
      def self.process(contagion)
        new(contagion).process
      end

      def process
        PostCreator.process(instant)
      end

      private

      attr_reader :contagion
      delegate :instants, to: :contagion

      def initialize(contagion)
        @contagion = contagion
      end

      def instant
        @instant ||= find_or_build_instant
      end

      def find_or_build_instant
        return InstantProcessor.process(ready_instant) if any_ready?

        instants.find_by(status: :created) ||
          Starter.process(contagion)
      end

      def ready_instant
        @ready_instant ||= instants.find_by(status: %i[ready processing])
      end

      def any_ready?
        ready_instant.present?
      end
    end
  end
end
