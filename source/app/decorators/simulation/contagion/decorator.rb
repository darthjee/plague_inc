# frozen_string_literal: true

require './app/models/simulation/contagion'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Decorator < ::Decorator
      Contagion::ALLOWED_ATTRIBUTES.each(&method(:expose))

      expose :groups
      expose :behaviors
    end
  end
end
