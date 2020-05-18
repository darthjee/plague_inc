# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      class Decorator < ::Decorator
        expose :name
      end
    end
  end
end
