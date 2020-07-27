# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InfectedInteractor
      include ::Processor

      def process
        population.interactions = 0;
        population.save
      end

      private

      attr_reader :population, :new_instant

      def initialize(population, new_instant)
        @population  = population
        @new_instant = new_instant
      end
    end
  end
end
