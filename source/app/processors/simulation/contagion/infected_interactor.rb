# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Consumes all interactions of a population
    #
    # Given an infected population, all it's interactions are
    # consumed by interactions with other populations (randomly)
    #
    # After the first interaction distribuition, all populations
    # that have interacted go through the process of infecting
    #
    # @see PopulationInfector
    class InfectedInteractor
      include ::Processor

      def process
        interact
        infect

        ActiveRecord::Base.transaction do
          save
        end
      end

      private

      attr_reader :population, :instant,
                  :new_instant, :options

      delegate :populations, to: :instant
      delegate :interaction_map, to: :interaction_store
      delegate :contagion, to: :instant
      delegate :simulation, to: :contagion
      delegate :interactions, to: :population

      def initialize(population, instant, new_instant, options)
        @population  = population
        @instant     = instant
        @new_instant = new_instant
        @options     = options
      end

      def interact
        options.interaction_block_size.times do
          break if interactions.zero?

          population.interactions -= 1
          interaction_store.interact
        end
      end

      def infect
        interaction_map.each do |pop, interactions|
          next unless pop.healthy?

          PopulationInfector.process(new_instant, population, pop, interactions)
        end
      end

      def populations
        @populations ||= instant.populations.reject(&:dead?)
      end

      def interaction_store
        @interaction_store ||= InstantInteractionStore.new(
          populations
        )
      end

      def save
        instant.save
        new_instant.save
        simulation.touch
      end
    end
  end
end
