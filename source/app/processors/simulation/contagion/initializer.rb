# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Creates a new instant to start processing
    class Initializer
      include ::Processor
      # @param instant [Instant] currently processed instant
      def initialize(instant)
        @instant = instant
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
        [
          Population::DEAD,
        ].each(&method(:build_aggregated_population_for))
        [
          Population::INFECTED,
          Population::HEALTHY,
          Population::IMMUNE
        ].each(&method(:build_population_for))
      end

      def build_aggregated_population_for(state)
        filtered_populations = populations.where(state: state)
        grouped_populations = filtered_populations.group(:group_id, :behavior_id)
        grouped_populations.sum(:size).each do |(group_id, behavior_id), size|
          group = Group.find(group_id)
          behavior = Behavior.find(behavior_id)

          Population::Builder.build(
            instant: new_instant,
            group: group,
            behavior: behavior,
            state: state,
            size: size,
            days: 1
          )
        end
      end

      def build_population_for(state)
        populations.where(state: state).each do |pop|
          Population::Builder.build(
            instant: new_instant,
            population: pop
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
