# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      # @author darthjee
      #
      # Exposes a summary of an instant
      class SummaryDecorator < Azeroth::Decorator
        include ::SummaryDecorator

        expose :id
        expose :status
        expose :day

        expose :total

        expose_counts :dead
        expose_counts :infected
        expose_counts :immune
        expose_counts :healthy

        def total
          @total ||= scoped_size(:all)
        end

        private

        def scoped_size(scope)
          populations
            .public_send(scope)
            .sum(:size)
        end
      end
    end
  end
end
