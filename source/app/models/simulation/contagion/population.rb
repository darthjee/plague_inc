# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      STATES = %w[healthy infected immune]

      scope :infected, -> { where.not(infected_days: nil) }
      scope :healthy, -> { where(infected_days: nil) }

      belongs_to :instant
      belongs_to :group
      belongs_to :behavior

      validates_presence_of :instant, :group, :behavior

      validates :size,
                presence: true,
                numericality: {
                  greater_than: 0,
                  only_integer: true
                }

      validates :infected_days,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  allow_nil: true
                }

      validates :state,
                presence: true,
                inclusion: { in: STATES }
    end
  end
end
