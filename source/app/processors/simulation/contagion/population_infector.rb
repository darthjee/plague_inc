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

      delegate :interact, :infected, :infection_map,
               to: :interaction_store

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

      def ignored_interactions
        infection_map.values.map do |value|
          healthy.behavior.interactions - value
        end.sum
      end

      def contagion_risk
        healthy.contagion_risk *
          infected_population.contagion_risk
      end

      def interaction_store
        @interaction_store ||= InteractionStore.new(
          contagion_risk, healthy
        )
      end
    end
  end
end
