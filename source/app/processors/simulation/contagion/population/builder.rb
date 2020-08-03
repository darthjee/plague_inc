# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      # @author darthjee
      #
      # Builds a population from options
      class Builder < Sinclair::Options
        with_options :instant, :group, :state,
                     :population, :behavior, :size,
                     :interactions

        # @param options [Hash] options
        # @option options instant [Instant] instant where new option will
        #   be created
        # @option options group [Group] population group
        # @option options behavior [Behavior] population behavior
        # @option options state [String,Symbo] initial state of
        #   population
        # @option options population [Population] population
        #   of a previous instant [Instant] to be used as model
        # @option options size [Integer] size of population
        # @option options interactions [Integer] ammount of actions
        #   left
        def self.build(*options)
          new(*options).build
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
          @built_population ||= find || build_population
        end

        def size
          @size ||= population ? population.size : public_send(state)
        end

        def find
          instant.populations.find do |pop|
            pop.group == group &&
              pop.state == state &&
              pop.days == days
          end
        end

        def build_population
          instant.populations.build(
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
