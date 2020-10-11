# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # {Simulation::Contagion} decoraror
    class Decorator < ::ModelDecorator
      Contagion::ALLOWED_ATTRIBUTES.each(&method(:expose))

      expose :groups
      expose :behaviors
    end
  end
end
