# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Group < ApplicationRecord
      ALLOWED_ATTRIBUTES = %i[name size reference].freeze

      belongs_to :contagion
      belongs_to :behavior

      validates_presence_of :contagion, :behavior
      validates :reference, length: { maximum: 10 }
      validates :name,
                presence: true,
                length: { maximum: 255 }
      validates :size,
                presence: true,
                numericality: { greater_than_or_equal_to: 1 }
    end
  end
end
