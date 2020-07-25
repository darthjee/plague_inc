# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Heals all populations, ready to be immunized
    class Healer
      # Heals all populations, ready to be immunized
      #
      # This is called after all processing of population
      # killings
      #
      # Only populations ready to be killed (days >= days_till_recovery)
      # are recovered
      #
      # @param instant [Instant]
      def self.process(instant)
        new(instant).process
      end

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

      def initialize(instant)
        @instant = instant
      end

      def population
        @population ||= populations.find do |pop|
          pop.infected? && pop.days >= days_till_recovery
        end
      end
    end
  end
end
