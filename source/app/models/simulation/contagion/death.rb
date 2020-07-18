# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Death
      def kill(population, size)
        return if size.zero?
        store[population.group] += size
        behaviors[population.group] = population.behavior
      end

      def store
        @store ||= Hash.new { 0 }
      end

      def behaviors
        @behaviors ||= {}
      end
    end
  end
end
