# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Decorator < ::Decorator
      ALLOWED_ATTRIBUTES.each(&method(:expose))

      expose :groups
      expose :behaviors
    end
  end
end
