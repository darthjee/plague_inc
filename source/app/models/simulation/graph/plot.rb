# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plot < ApplicationRecord
      validates :label,
                presence: true,
                length: { maximum: 255 }
      validates :field,
                presence: true,
                length: { maximum: 255 }
      validates :metric,
                presence: true,
                length: { maximum: 255 }
    end
  end
end
