# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Killer
      def self.process(instant)
        new(instant).process
      end

      def process
        ready_to_die.each do |population|
          Death.process(population, contagion)
        end
      end

      private

      attr_reader :instant, :contagion

      def initialize(instant)
        @instant = instant
      end

      delegate :contagion, to: :instant
      delegate :populations, to: :instant
      delegate :days_till_start_death, to: :contagion

      def ready_to_die
        populations
          .select(&:infected?)
          .select do |pop|
          pop.days >= days_till_start_death
        end
      end
    end
  end
end
