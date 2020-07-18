# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      class Builder
        def self.build(instant:, group: nil, state: nil, population: nil, behavior: nil, interactions: nil, size: nil)
          new(
            instant: instant,
            group: group,
            population: population,
            state: state,
            behavior: behavior,
            interactions: interactions,
            size: size
          ).build
        end

        def build
          scope.build(
            size: size,
            days: days,
            interactions: interactions
          )
        end

        private

        attr_reader :population, :instant

        delegate :infected, :healthy, to: :group

        def initialize(instant:, group:, population:, state:, behavior:, interactions:, size:)
          @instant      = instant
          @group        = group
          @state        = state
          @population   = population
          @behavior     = behavior
          @interactions = interactions
          @size         = size
        end

        def size
          @size ||= population ? population.size : public_send(state)
        end

        def scope
          instant.populations.where(
            group: group,
            behavior: behavior,
            state: state
          )
        end

        def group
          @group ||= population.group
        end

        def state
          @state ||= population.state
        end

        def days
          population ? population.days + 1 : 0
        end

        def interactions
          @interactions ||= size * behavior.interactions
        end

        def behavior
          @behavior ||= group.behavior
        end
      end
    end
  end
end
