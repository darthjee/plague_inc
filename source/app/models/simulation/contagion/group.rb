# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      belongs_to :contagion

      validates_presence_of :name, :contagion
    end
  end
end
