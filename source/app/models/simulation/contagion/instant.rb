# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      STATUSES = %w[
        created processing processed
      ].freeze

      belongs_to :contagion
      belongs_to :current_population,
                 optional: true,
                 class_name: 'Population'

      validates_presence_of :contagion

      validates :day,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true
                }
      validates :status,
                presence: true,
                inclusion: { in: STATUSES }
    end
  end
end
