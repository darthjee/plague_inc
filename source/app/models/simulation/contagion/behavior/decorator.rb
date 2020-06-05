# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Behavior < ApplicationRecord
      class Decorator < ::Decorator
        ALLOWED_ATTRIBUTES.each(&method(:expose))
      end
    end
  end
end
