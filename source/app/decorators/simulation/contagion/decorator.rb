# frozen_string_literal: true

require './app/models/simulation/contagion'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # {Simulation::Contagion} decoraror
    class Decorator < ::ModelDecorator
      Contagion::ALLOWED_ATTRIBUTES.each(&method(:expose))

      expose :groups
      expose :behaviors
      expose :current_day

      def current_day
        current_instant&.day
      end
    end
  end
end
