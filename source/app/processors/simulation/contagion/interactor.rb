# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Interactor
      include ::Processor

      def process
        instant.status = Instant::PROCESSED

        instant.save
      end

      private

      attr_reader :instant

      def initialize(instant, new_instant)
        @instant     = instant
        @new_instant = new_instant
      end
    end
  end
end
