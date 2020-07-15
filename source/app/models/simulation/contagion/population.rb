# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      INFECTED = 'infected'
      HEALTHY  = 'healthy'
      IMMUNE   = 'immune'

      STATES = [INFECTED, HEALTHY, IMMUNE].freeze

      scope :infected, -> { where(state: :infected) }
      scope :healthy, -> { where(state: :healthy) }

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

      validates :days,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true
                }

      validates :state,
                presence: true,
                inclusion: { in: STATES }

      def infected?
        state == INFECTED
      end
    end
  end
end
