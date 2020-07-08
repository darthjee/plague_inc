# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name size infected reference].freeze

      belongs_to :contagion
      belongs_to :behavior

      validates_presence_of :contagion, :behavior
      validates :reference,
                presence: true,
                length: { maximum: 10 }
      validates :name,
                presence: true,
                length: { maximum: 255 }
      validates :size,
                presence: true,
                numericality: { greater_than_or_equal_to: 1 }
      validates :infected,
                numericality: { greater_than_or_equal_to: 0 }

      validate :validate_infected

      def validate_infected
        return unless size
        return unless infected.to_i > size

        errors.add(
          :infected,
          'cannot be greater than group size'
        )
      end
    end
  end
end
