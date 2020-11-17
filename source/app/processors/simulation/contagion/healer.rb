# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Heals all populations, ready to be immunized
    class Healer
      include ::Processor

      # @param instant [Instant]
      def initialize(instant)
        @instant = instant
      end

      # Heals all populations, ready to be immunized
      #
      # This is called after all processing of population
      # killings
      #
      # Only populations ready to be killed (days >= days_till_recovery)
      # are recovered
      def process
        return unless population

        population.state = Population::IMMUNE
        population.days  = 0
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :days_till_recovery, to: :contagion
      delegate :populations, to: :instant

      def population
        @population ||= populations.find do |pop|
          pop.infected? && pop.days >= days_till_recovery
        end
      end
    end
  end
end
