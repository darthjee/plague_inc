# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantInteractionStore
      def initialize(populations)
        @populations = populations
      end

      def interact
        return unless interactions?

        interact_with(next_interaction)
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      private

      attr_reader :populations

      def interact_with(population)
        interaction_map[population] += 1
        population.interactions -= 1
      end

      def next_interaction
        index = next_interaction_index

        populations.inject(0) do |previous_index, pop|
          (previous_index + pop.interactions).tap do |max|
            return pop if index < max
          end
        end
      end

      def next_interaction_index
        random_box.interaction(max_interactions)
      end

      def interactions?
        max_interactions.positive?
      end

      def max_interactions
        populations.map(&:interactions).sum
      end

      def random_box
        @random_box ||= RandomBox.instance
      end
    end
  end
end
