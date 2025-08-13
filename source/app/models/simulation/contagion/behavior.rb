# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Behavior followed by a population
    class Behavior < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name interactions contagion_risk reference].freeze

      belongs_to :contagion

      validates_presence_of :contagion
      validates :name,
                presence: true,
                length: { maximum: 255 }
      validates :reference,
                presence: true,
                length: { maximum: 10 }
      validates :interactions,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 2_147_483_648 # limite do INT no MySQL
                }
      validates :contagion_risk,
                presence: true,
                inclusion: { in: (0.0..1.0) }
    end
  end
end
