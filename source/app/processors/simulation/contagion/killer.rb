# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Killer
      def self.process(instant)
        new(instant).process
      end

      def process
        ready_to_die.map do |population|
          dead = Kill.process(population, contagion)
          next if dead.zero?

          death.kill(population, dead)
        end

        death.deaths.each do |group, dead|
          Population::Builder.build(
            instant: instant,
            group: group,
            behavior: death.behavior(group),
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

      def death
        @death ||= Death.new
      end
    end
  end
end
