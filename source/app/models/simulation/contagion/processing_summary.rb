# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class ProcessingSummary
      attr_reader :instant, :interactions
      
      delegate :id, :status, :day,
        :populations, to: :instant

      def initialize(instant, interactions: 0)
        @instant = instant
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        other.interactions == interactions &&
          other.instant == instant
      end

      def reload
        instant.reload
        self
      end
    end
  end
end
