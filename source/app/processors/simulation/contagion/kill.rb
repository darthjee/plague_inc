# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Randomly kills people of an infected population
    class Kill < ::Processor
      # @param population [Population] population to be killed
      # @param contagion [Contagion] Simulation params
      def initialize(population, contagion)
        @population = population
        @contagion  = contagion
      end

      # Kills people from an infected population
      #
      # Killings happen by trying ot kill randomly,
      # aiming for the given lethality
      def process
        population.size = alive
        current - alive
      end

      private

      attr_reader :population, :contagion
      delegate :lethality, to: :contagion

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
