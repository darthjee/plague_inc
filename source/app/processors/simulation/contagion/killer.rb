# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Killer
      def self.process(instant)
        new(instant).process
      end

      def process
        @killed ||= ready_to_die.map do |population|
          dead = Death.process(population, contagion)
          next if dead.zero?
          Population::Builder.build(
            instant: instant,
            group: population.group,
            behavior: population.behavior,
            size: dead,
            state: :dead,
            interactions: 0
          )
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
