# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Infect a healthy population
    class PopulationInfector
      include ::Processor
      include Contagion::Cacheable

      # @param instant [Instant] instant where new infected population will
      #   be created
      # @param infected_population [Population] poppulation infecting healthy
      #   population
      # @param healthy [Population] healthy population being infected
      # @param interactions [Integer] number of interactions between
      #   populations
      def initialize(
        instant, infected_population, healthy, interactions, cache:
      )
        @instant              = instant
        @infected_population  = infected_population
        @healthy              = healthy
        @interactions         = interactions
        @cache                = cache
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
        healthy.new_infections += infected
        healthy.interactions -= ignored_interactions
      end

      def build_population
        Population::Builder.build(
          instant: instant,
          group: with_cache(healthy, :group),
          behavior: with_cache(healthy, :behavior),
          state: Population::INFECTED,
          size: infected,
          cache: cache
        )
      end

      def contagion_risk
        healthy.contagion_risk *
          infected_population.contagion_risk
      end

      def interaction_store
        @interaction_store ||= InteractionStore.new(
          contagion_risk, healthy, cache: cache
        )
      end
    end
  end
end
