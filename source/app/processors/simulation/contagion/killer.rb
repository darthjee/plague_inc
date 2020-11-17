# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Kills people from populations of an instant
    class Killer
      include ::Processor
      include Contagion::Cacheable

      # @param instant [Instant] instant to be processed
      def initialize(instant, cache:)
        @instant = instant
        @cache   = cache
      end

      # Kills people from populations of an instant
      #
      # All infected populations that are ready to be killed
      # (days >= days_till_start_death) is randomly killed
      def process
        calculate_deaths
        death.deaths.each(&method(:build_dead))
      end

      private

      attr_reader :instant, :contagion

      delegate :contagion, to: :instant
      delegate :populations, to: :instant
      delegate :days_till_start_death, to: :contagion

      def calculate_deaths
        ready_to_die.map do |population|
          dead = Kill.process(population, contagion)
          next if dead.zero?

          death.kill(population, dead)
        end
      end

      def ready_to_die
        populations
          .select(&:infected?)
          .select do |pop|
          pop.days >= days_till_start_death
        end
      end

      def death
        @death ||= Death.new(cache: nil)
      end

      def build_dead(group, dead)
        Population::Builder.build(
          instant: instant,
          group: group,
          behavior: death.behavior(group),
          size: dead,
          state: :dead,
          cache: cache
        )
      end
    end
  end
end
