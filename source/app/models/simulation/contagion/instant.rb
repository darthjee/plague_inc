# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      belongs_to :contagion

      validates_presence_of :contagion, :status

      validates :day,
                presence: true,
                numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
