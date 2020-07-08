# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      class Decorator < ::Decorator
        ALLOWED_ATTRIBUTES.each(&method(:expose))

        expose :behavior
        expose :infected

        def behavior
          object.behavior&.reference
        end
      end
    end
  end
end
