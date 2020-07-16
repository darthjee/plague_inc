# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      class Builder
        def self.build(instant:, group:, type:)
          new(
            instant: instant,
            group: group,
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

        attr_reader :group, :instant, :type

        delegate :behavior, :infected, :healthy, to: :group

        def initialize(instant:, group:, type:)
          @instant = instant
          @group   = group
          @type    = type
        end

        def size
          public_send(type)
        end

        def scope
          instant.populations.public_send(type)
        end
      end
    end
  end
end
