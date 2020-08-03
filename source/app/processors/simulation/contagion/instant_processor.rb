# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantProcessor
      def self.process(instant)
        new(instant).process
      end

      def process
        Contagion::Interactor.process(instant, new_instant)

        instant.update(status: Instant::PROCESSED)

        new_instant
      end

      private

      attr_reader :instant

      def initialize(instant)
        @instant = instant
      end

      def new_instant
        @new_instant ||= Initializer.process(instant)
      end
    end
  end
end
