# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      class Builder
        def self.build(instant:, group: nil, state: nil, population: nil)
          new(
            instant: instant,
            group: group,
            population: population,
            state: state
          ).build
        end

        def build
          scope.build(
            size: size,
            days: days
          )
        end

        private

        attr_reader :population, :instant

        delegate :behavior, :infected, :healthy, to: :group

        def initialize(instant:, group:, population:, state:)
          @instant    = instant
          @group      = group
          @state      = state
          @population = population
        end

        def size
          population ? population.size : public_send(state)
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
      end
    end
  end
end
