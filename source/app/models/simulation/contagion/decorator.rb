# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Decorator < ::Decorator
      expose :lethality
      expose :days_till_recovery
      expose :days_till_sympthoms
      expose :days_till_start_death
    end
  end
end
