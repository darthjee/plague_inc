# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      belongs_to :contagion

      validates_presence_of :name, :contagion
      validates :size,
                presence: true,
                numericality: { greater_than_or_equal_to: 1 }
    end
  end
end
