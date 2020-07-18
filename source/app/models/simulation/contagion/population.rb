# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      INFECTED = 'infected'
      HEALTHY  = 'healthy'
      IMMUNE   = 'immune'
      DEAD     = 'dead'

      STATES = [INFECTED, HEALTHY, IMMUNE, DEAD].freeze

      scope :infected,    -> { where(state: INFECTED) }
      scope :healthy,     -> { where(state: HEALTHY) }
      scope :immune,      -> { where(state: IMMUNE) }
      scope :not_healthy, -> { where.not(state: HEALTHY) }

      belongs_to :instant
      belongs_to :group
      belongs_to :behavior

      validates_presence_of :instant, :group, :behavior

      validates :size,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
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

      validates :interactions,
                presence: true,
                numericality: {
                  greater_than: 0,
                  only_integer: true
                }

      def infected?
        state == INFECTED
      end

      def healthy?
        state == HEALTHY
      end
    end
  end
end
