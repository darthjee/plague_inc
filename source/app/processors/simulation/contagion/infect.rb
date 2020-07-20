# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Infect
      def self.process(instant, infected_population, healthy, interactions)
        new(instant, infected_population, healthy, interactions).process
      end

      def process
        interactions.times.inject(0) do |counter, _|
          next unless (random_box < contagion_risk)
          infect
        end

        @infected = infection_map.keys.size

        return if infected.zero?
        healthy.interactions = 0

        Population::Builder.build(
          instant: instant,
          group: healthy.group,
          behavior: healthy.behavior,
          state: Population::INFECTED,
          size: infected
        )
      end

      private

      attr_reader :instant, :infected, :infected_population, :healthy, :interactions

      def initialize(instant, infected_population, healthy, interactions)
        @instant                 = instant
        @infected_population     = infected_population
        @healthy                 = healthy
        @interactions            = interactions
      end

      def random_box
        @random_box ||= RandomBox.new
      end

      def infect
        infection_map[next_infected] += 1
      end

      def next_infected
        loop do
          index = random_box.person(healthy.size)
          return index if infection_map[index] < healthy.behavior.interactions
        end
      end

      def infection_map
        @infection_map ||= Hash.new { 0 }
      end

      def contagion_risk
        @contagion_risk ||= healthy.contagion_risk *
          infected_population.contagion_risk
      end
    end
  end
end
