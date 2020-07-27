# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Infect a healthy population
    class PopulationInfector < ::Processor
      # @param instant [Instant] instant where new infected population will
      #   be created
      # @param infected_population [Population] poppulation infecting healthy
      #   population
      # @param healthy [Population] healthy population being infected
      # @param interactions [Integer] number of interactions between
      #   populations
      def initialize(instant, infected_population, healthy, interactions)
        @instant                 = instant
        @infected_population     = infected_population
        @healthy                 = healthy
        @interactions            = interactions
      end

      # Infect healthy population
      #
      # infection will happen based on contagion risk
      # between two populations as a product of their
      # contagion_risk
      def process
        interactions.times { interact }

        return if infected.zero?

        update_healthy
        build_population
      end

      private

      attr_reader :instant, :healthy,
                  :infected_population, :interactions

      delegate :interact, :infected, :ignored_interactions,
               to: :interaction_store

      def update_healthy
        healthy.interactions -= ignored_interactions
        healthy.new_infections += infected
        healthy.interactions = 0 if healthy.interactions.negative?
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
