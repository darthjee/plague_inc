# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Population < ApplicationRecord
      belongs_to :instant
      belongs_to :group
      belongs_to :behavior

      validates_presence_of :instant, :group, :behavior

      validates :infected_days,
                numericality: {
                  greater_than_or_equal_to: 0,
                  only_integer: true,
                  allow_nil: true
                }
    end
  end
end
