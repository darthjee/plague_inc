# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InfectedInteractor
      include ::Processor

      def process
        loop do
          break if population.interactions.zero?
          population.interactions -= 1
          interaction_store.interact
        end

        instant.save
      end

      private

      attr_reader :population, :instant, :new_instant

      delegate :populations, to: :instant

      def initialize(population, instant, new_instant)
        @population  = population
        @instant = instant
        @new_instant = new_instant
      end

      def interaction_store
        @interaction_store ||= InstantInteractionStore.new(
          populations
        )
      end
    end
  end
end
