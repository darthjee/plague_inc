# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Death
      def self.process(population, contagion)
        new(population, contagion).process
      end

      def process
        population.size = alive
        current - alive
      end

      private

      attr_reader :population, :contagion
      delegate :lethality, to: :contagion

      def initialize(population, contagion)
        @population = population
        @contagion  = contagion
      end

      def alive
        current.times.inject(current) do |people, _|
          Random.rand < lethality ? people - 1 : people
        end
      end

      def current
        @current ||= population.size
      end
    end
  end
end
