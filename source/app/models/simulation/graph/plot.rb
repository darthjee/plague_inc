# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plot < ApplicationRecord
      FIELDS = Contagion::Instant::SummaryDecorator
               .counts_exposed.dup.freeze

      METRICS = %w[value average max min].freeze

      belongs_to :graph
      belongs_to :simulation

      validates_presence_of :graph, :simulation

      validates :label,
                presence: true,
                length: { maximum: 255 }
      validates :field,
                presence: true,
                inclusion: { in: FIELDS }
      validates :metric,
                presence: true,
                inclusion: { in: METRICS }

      def plot_data
        [
          plot_x_data,
          plot_y_data
        ]
      end

      private

      def plot_x_data
        simulation.contagion.instants.map(&:day)
      end

      def plot_y_data
        simulation.contagion.instants.map do |instant|
          instant.populations.public_send(field).sum(:size)
        end
      end
    end
  end
end
