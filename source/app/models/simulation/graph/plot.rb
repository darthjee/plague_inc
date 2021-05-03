# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plot < ApplicationRecord
      FIELDS = Contagion::Instant::SummaryDecorator.counts_exposed

      validates :label,
                presence: true,
                length: { maximum: 255 }
      validates :field,
                presence: true,
                length: { maximum: 19 }
                #inclusion: { in: FILEDS },
      validates :metric,
                presence: true,
                length: { maximum: 255 }
    end
  end
end
