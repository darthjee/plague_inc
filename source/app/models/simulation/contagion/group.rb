# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name size].freeze

      belongs_to :contagion

      validates_presence_of :name, :contagion
      validates :size,
                presence: true,
                numericality: { greater_than_or_equal_to: 1 }
    end
  end
end
