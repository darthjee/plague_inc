# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InteractionStore
      def initialize(contagion_risk, population)
        @contagion_risk = contagion_risk
        @population     = population
      end

      def interact
        index = next_interaction
        interaction_map[index] += 1

        return unless random_box < contagion_risk

        infect(index)
      end

      def ignored_interactions
        infection_map.map do |index|
          behavior_interactions - interaction_map[index]
        end.sum
      end

      def infected
        infection_map.size
      end

      private

      attr_reader :contagion_risk, :population

      def infect(index)
        infection_map << index
      end

      def next_interaction
        loop do
          index = random_box.person(population_size)
          return index if interactions?(index)
        end
      end

      def interactions?(index)
        interaction_map[index] < behavior_interactions
      end

      def population_size
        population.size - population.new_infections
      end

      def behavior_interactions
        population.behavior.interactions
      end

      def random_box
        @random_box ||= RandomBox.new
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      def infection_map
        @infection_map ||= Set.new
      end
    end
  end
end
