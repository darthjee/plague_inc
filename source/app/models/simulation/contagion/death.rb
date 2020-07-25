# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Model to store deaths of groups
    class Death
      # kills people from a population
      #
      # After the kill stores the behavior
      # for later creation of killed population
      #
      # @param population [Population] population
      #   to be killed
      # @param size [Integer] number of people killed
      def kill(population, size)
        return if size.zero?

        group = population.group
        deaths[group] += size
        behaviors[group] = population.behavior
      end

      def deaths
        @deaths ||= Hash.new { 0 }
      end

      def behavior(group)
        behaviors[group]
      end

      private

      def behaviors
        @behaviors ||= {}
      end
    end
  end
end
