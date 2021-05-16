# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class ProcessingSummary
      attr_reader :instant, :interactions
      
      delegate :id, :status, :day, :total,
        :dead_percentage, :infected_percentage,
        :immune_percentage, :healthy_percentage,
        :recent_dead, :recent_infected,
        :recent_immune, :recent_healthy,
        to: :instant

      def initialize(instant, interactions: 0)
        @instant = instant
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        other.interactions == interactions &&
          other.instant == instant
      end
    end
  end
end
