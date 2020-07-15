# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PostCreator
      def initialize(instant)
        @instant = instant
      end

      def process
        Killer.new(instant, contagion).process
        instant.save
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
    end
  end
end
