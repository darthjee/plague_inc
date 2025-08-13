# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Group of people which will generate populations
    class Group < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name size infected reference].freeze

      belongs_to :contagion
      belongs_to :behavior

      validates_presence_of :contagion, :behavior
      validates :reference,
                presence: true,
                length: { maximum: 10 },
                uniqueness: { scope: :contagion_id }
      validates :name,
                presence: true,
                length: { maximum: 255 }
      validates :size,
                presence: true,
                numericality: {
                  greater_than_or_equal_to: 1,
                  only_integer: true,
                  less_than: 2_147_483_648 # INT MySQL limit
                }
      validates :infected,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  less_than: 2_147_483_648 # INT MySQL limit
                }

      validate :validate_infected

      def validate_infected
        return unless size
        return unless infected.to_i > size

        errors.add(
          :infected,
          'cannot be greater than group size'
        )
      end

      def healthy
        size - infected
      end

      def any_infected?
        !infected.zero?
      end

      def any_healthy?
        !healthy.zero?
      end
    end
  end
end
