# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      # @author darthjee
      class AggregatedBuilder < Sinclair::Options
        with_options :populations, :instant, :state

        def self.build(*options)
          new(*options).build
        end

        def build
          grouped_populations.sum(:size).each do |(group_id, behavior_id), size|
            next if size.zero?

            build_population(group_id, behavior_id, size)
          end
        end

        private

        def filtered_populations
          @filtered_populations ||= populations.where(state: state)
        end

        def grouped_populations
          @grouped_populations ||= filtered_populations.group(
            :group_id, :behavior_id
          )
        end

        def build_population(group_id, behavior_id, size)
          group = Group.find(group_id)
          behavior = Behavior.find(behavior_id)

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
