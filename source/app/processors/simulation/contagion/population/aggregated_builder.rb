# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      # @author darthjee
      #
      # Groups populations to create a new population in
      # the new instant
      class AggregatedBuilder < Sinclair::Options
        include Contagion::Cacheable
        include ::Processor

        with_options :populations, :instant, :state
        skip_validation

        class << self
          # @method build
          # @param options [Hash] options
          # @option options populations
          #   [ActiveRelation<Simulation::Contagion::Population>] base
          #   scope of populations
          # @option options instant [Simulation::Contagion::Instant]
          #   new instant where population will be built
          # @option options state [Symbol, String] filter of
          #   state
          alias build process
        end

        def process
          grouped_populations.sum(:size).each do |group_id, size|
            build_population(group_id, size)
          end
        end

        private

        def filtered_populations
          @filtered_populations ||= populations.where(state: state)
        end

        def grouped_populations
          @grouped_populations ||= filtered_populations.group(:group_id)
        end

        def build_population(group_id, size)
          group = from_cache(:group, group_id)
          behavior = with_cache(group, :behavior)

          Population::Builder.build(
            instant: instant,
            group: group,
            behavior: behavior,
            state: state,
            size: size,
            days: 1
          )
        end
      end
    end
  end
end
