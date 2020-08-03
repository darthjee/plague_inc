# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Store for all interactions happening in a population
    class InteractionStore
      # @param contagion_risk [Float] risk of contagion
      # @param population [Population] population to
      #   perform interactions
      def initialize(contagion_risk, population)
        @contagion_risk = contagion_risk
        @population     = population
      end

      # Simulate an interaction
      #
      # stores the result of the simulation
      # in the map of interactions and infections
      def interact
        index = next_interaction
        interaction_map[index] += 1

        return unless random_box < contagion_risk

        infect(index)
      end

      # Returns interactions that should be ignored
      #
      # interactions are ignored when a person is
      # infected, as the rest of its interactions
      # dont need to be simulated
      def ignored_interactions
        [
          infected_max_interactions - infected_interactions,
          population.interactions
        ].min
      end

      def infected
        infection_map.size
      end

      private

      attr_reader :contagion_risk, :population

      def infect(index)
        infection_map[index] += 1
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

      def infected_max_interactions
        infection_map.size * behavior_interactions
      end

      def infected_interactions
        infection_map.values.sum
      end

      def random_box
        @random_box ||= RandomBox.instance
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      def infection_map
        @infection_map ||= Hash.new { 0 }
      end
    end
  end
end
