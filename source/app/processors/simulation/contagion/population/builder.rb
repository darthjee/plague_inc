# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      class Builder < Sinclair::Options
        with_options :instant, :group, :state,
                     :population, :behavior, :size,
                     :interactions

        def self.build(*args)
          new(*args).build
        end

        def build
          built_population.size += size
          built_population.interactions = interactions
          built_population.behavior = behavior

          built_population
        end

        private

        attr_reader :population, :instant

        delegate :infected, :healthy, to: :group

        def built_population
          @built_population ||= scope.first_or_initialize
        end

        def size
          @size ||= population ? population.size : public_send(state)
        end

        def scope
          instant.populations.where(
            group: group,
            state: state,
            days: days
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
