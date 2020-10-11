# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Behavior < ApplicationRecord
      # {Simulation::Contagion::Behavior} decoraror
      class Decorator < ::ModelDecorator
        Behavior::ALLOWED_ATTRIBUTES.each(&method(:expose))
      end
    end
  end
end
