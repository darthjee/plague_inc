# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InfectedInteractor
      include ::Processor

      def process
      end

      private

      attr_reader :population, :populations, :new_instant

      def initialize(population, populations, new_instant)
        @population  = population
        @populations = populations
        @new_instant = new_instant
      end

      def interaction_store
        @interaction_store ||= InstantInteractionStore.new(
          instant
        )
      end
    end
  end
end
