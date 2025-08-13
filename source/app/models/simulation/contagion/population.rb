# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Instant population of people
    class Population < ApplicationRecord
      INFECTED = 'infected'
      HEALTHY  = 'healthy'
      IMMUNE   = 'immune'
      DEAD     = 'dead'

      STATES = [INFECTED, HEALTHY, IMMUNE, DEAD].freeze

      delegate :contagion_risk, to: :behavior

      scope :infected,    -> { where(state: INFECTED) }
      scope :healthy,     -> { where(state: HEALTHY) }
      scope :immune,      -> { where(state: IMMUNE) }
      scope :dead,        -> { where(state: DEAD) }
      scope :not_healthy, -> { where.not(state: HEALTHY) }
      scope :alive,       -> { where.not(state: DEAD) }
      scope :recent,      -> { where(days: 0) }
      scope :not_empty,   -> { where.not(size: 0) }
      scope :empty,       -> { where(size: 0) }

      scope :with_population, -> { where('size > ?', 0) }

      belongs_to :instant
      belongs_to :group
      belongs_to :behavior

      validates_presence_of :instant, :group, :behavior

      validates :size,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 18_446_744_073_709_551_616 # BIGINT UNSIGNED MySQL limit
                }

      validates :days,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 65_536 # SMALLINT MySQL limit (limit: 2)
                }

      validates :interactions,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 9_223_372_036_854_775_808  # BIGINT MySQL limit
                }

      validates :new_infections,
                numericality: {
                  greater_than_or_equal_to: 0,
                  allow_nil: true,
                  only_integer: true,
                  less_than: 2_147_483_648  # INT MySQL limit
                }

      validates :state,
                presence: true,
                inclusion: { in: STATES },
                length: { maximum: 255 }

      def infected?
        state == INFECTED
      end

      def healthy?
        state == HEALTHY
      end

      def dead?
        state == DEAD
      end

      def remaining_size
        size - new_infections
      end

      def interactions?
        interactions.positive?
      end

      def setup_interactions
        self.interactions = behavior.interactions * size
      end
    end
  end
end
