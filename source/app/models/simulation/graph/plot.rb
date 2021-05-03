# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plot < ApplicationRecord
      FIELDS = Contagion::Instant::SummaryDecorator
               .counts_exposed.dup.freeze

      METRICS = %w[value average max min].freeze

      validates :label,
                presence: true,
                length: { maximum: 255 }
      validates :field,
                presence: true,
                inclusion: { in: FIELDS }
      validates :metric,
                presence: true,
                inclusion: { in: METRICS }
    end
  end
end
