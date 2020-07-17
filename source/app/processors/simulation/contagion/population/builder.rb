# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      class Builder
        def self.build(instant:, group: nil, type: nil, population: nil)
          new(
            instant: instant,
            group: group,
            population: population,
            type: type
          ).build
        end

        def build
          scope.build(
            group: group,
            behavior: behavior,
            size: size
          )
        end

        private

        attr_reader :population, :instant

        delegate :behavior, :infected, :healthy, to: :group

        def initialize(instant:, group:, population:, type:)
          @instant    = instant
          @group      = group
          @type       = type
          @population = population
        end

        def size
          public_send(type)
        end

        def scope
          instant.populations.public_send(type)
        end

        def group
          @group ||= population.group
        end

        def type
          @type ||= population.state
        end
      end
    end
  end
end
