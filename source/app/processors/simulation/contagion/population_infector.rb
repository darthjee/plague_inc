# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PopulationInfector
      def self.process(instant, infected_population, healthy, interactions)
        new(instant, infected_population, healthy, interactions).process
      end

      def process
        interactions.times.inject(0) do |_counter, _|
          interact
        end

        return if infected.zero?

        healthy.interactions -= ignored_interactions
        healthy.new_infections += infected

        build_population
      end

      private

      attr_reader :instant, :healthy,
                  :infected_population, :interactions

      def initialize(instant, infected_population, healthy, interactions)
        @instant                 = instant
        @infected_population     = infected_population
        @healthy                 = healthy
        @interactions            = interactions
      end

      def build_population
        Population::Builder.build(
          instant: instant,
          group: healthy.group,
          behavior: healthy.behavior,
          state: Population::INFECTED,
          size: infected
        )
      end

      def infected
        @infected ||= infection_map.size
      end

      def ignored_interactions
        interaction_map.values.map do |value|
          healthy.behavior.interactions - value
        end.sum
      end

      def random_box
        @random_box ||= RandomBox.new
      end

      def interact
        index = next_interaction
        interaction_map[index] += 1
        infect(index) if random_box < contagion_risk
      end

      def infect(index)
        infection_map << index
      end

      def infection_map
        @infection_map ||= Set.new
      end

      def next_interaction
        loop do
          index = random_box.person(healthy_size)
          return index if interaction_map[index] < healthy.behavior.interactions
        end
      end

      def healthy_size
        healthy.size - healthy.new_infections
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      def contagion_risk
        @contagion_risk ||= healthy.contagion_risk *
                            infected_population.contagion_risk
      end
    end
  end
end
