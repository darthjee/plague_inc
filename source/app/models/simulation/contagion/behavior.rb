# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Behavior < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name interactions contagion_risk reference].freeze

      belongs_to :contagion

      validates_presence_of :contagion
      validates :reference, length: { maximum: 10 }
      validates :interactions,
                presence: true,
                numericality: { greater_than_or_equal_to: 0 }
      validates :contagion_risk,
                presence: true,
                inclusion: { in: (0.0..1.0) }
    end
  end
end
