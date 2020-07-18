# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Death
      def kill(population, size)
        return if size.zero?

        deaths[population.group] += size
        behaviors[population.group] = population.behavior
      end

      def deaths
        @deaths ||= Hash.new { 0 }
      end

      def behavior(group)
        behaviors[group]
      end

      def behaviors
        @behaviors ||= {}
      end
    end
  end
end
