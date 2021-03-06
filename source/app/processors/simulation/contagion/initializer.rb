# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Creates a new instant to start processing
    class Initializer
      include ::Processor
      include Contagion::Cacheable

      # @param instant [Instant] currently processed instant
      def initialize(instant, cache:)
        @instant = instant
        @cache   = cache
      end

      # Creates a new instant.copying all not healthy populations
      #
      # @return [Instant] newly built and saved instant
      def process
        instant.status = Instant::PROCESSING

        new_instant.tap do
          build_populations
          save
        end
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :populations, to: :instant
      delegate :not_healthy, to: :populations
      delegate :simulation, to: :contagion

      def new_instant
        @new_instant ||= contagion.instants.build(
          day: instant.day + 1
        )
      end

      def build_populations
        build_dead_populations
        build_immune_populations
        build_infected_populations
      end

      def build_dead_populations
        aggregate_populations(Population::DEAD)
      end

      def aggregate_populations(state)
        Population::AggregatedBuilder.build(
          populations: populations.where(state: state),
          instant: new_instant,
          state: state,
          cache: cache
        )
      end

      def build_immune_populations
        if contagion.immunization_ends?
          build_population_for(Population::IMMUNE)
        else
          aggregate_populations(Population::IMMUNE)
        end
      end

      def build_infected_populations
        build_population_for(Population::INFECTED)
      end

      def build_population_for(state)
        populations.where(state: state).each do |pop|
          Population::Builder.build(
            instant: new_instant,
            population: pop,
            cache: cache
          )
        end
      end

      def save
        ActiveRecord::Base.transaction do
          new_instant.save
          instant.save
          simulation.touch
        end
      end
    end
  end
end
