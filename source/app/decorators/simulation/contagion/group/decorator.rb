# frozen_string_literal: true

require './app/models/simulation/contagion/group'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      class Decorator < ::Decorator
        Group::ALLOWED_ATTRIBUTES.each(&method(:expose))

        expose :behavior

        def behavior
          object.behavior&.reference
        end
      end
    end
  end
end
