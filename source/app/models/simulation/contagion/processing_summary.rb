# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class ProcessingSummary
      attr_reader :instant
      
      delegate :id, :status, :day, :total,
        :dead_percentage, :infected_percentage,
        :immune_percentage, :healthy_percentage,
        :recent_dead, :recent_infected,
        :recent_immune, :recent_healthy,
        to: :instant

      def initialize(instant)
        @instant = instant
      end

      def interactions
        @interactions ||= 0
      end
    end
  end
end
