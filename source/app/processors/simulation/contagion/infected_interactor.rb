# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InfectedInteractor
      include ::Processor

      def process
        population.interactions.times do
          index = max_interactions
        end

        population.interactions = 0;
        population.save
      end

      private

      attr_reader :population, :populations, :new_instant

      def initialize(population, populations, new_instant)
        @population  = population
        @populations = populations
        @new_instant = new_instant
      end

      def selected_population
        index = 0

        populations.select do |pop|

        end
      end

      def next_interaction
        random_box.interact(max_interactions)
      end

      def interaction_store
        @interaction_store ||= Hash.new(0)
      end

      def max_interactions
        populations.map(&:interactions)
      end

      def random_box
        @random_box ||= RandomBox.instance
      end
    end
  end
end
