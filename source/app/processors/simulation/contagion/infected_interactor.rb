# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InfectedInteractor
      include ::Processor

      def process
        interact
        infect

        ActiveRecord::Base.transaction do
          instant.save
          new_instant.save
        end
      end

      private

      attr_reader :population, :instant, :new_instant

      delegate :populations, to: :instant
      delegate :interaction_map, to: :interaction_store

      def initialize(population, instant, new_instant)
        @population = population
        @instant = instant
        @new_instant = new_instant
      end

      def interact
        loop do
          break if population.interactions.zero?

          population.interactions -= 1
          interaction_store.interact
        end
      end

      def infect
        interaction_map.each do |pop, interactions|
          next unless pop.healthy?

          PopulationInfector.process(new_instant, population, pop, interactions)
        end
      end

      def populations
        @populations ||= instant.populations.reject(&:dead?)
      end

      def interaction_store
        @interaction_store ||= InstantInteractionStore.new(
          populations
        )
      end
    end
  end
end
