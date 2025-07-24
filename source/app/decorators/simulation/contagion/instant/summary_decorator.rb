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

        expose_counts :dead, :infected, :immune, :healthy

        def total
          @total ||= scoped_size(:all)
        end

        private

        def scoped_size(scope)
          scoped(scope)
            .sum(:size)
        end

        def recent_scoped_size(scope)
          return 0 if object.day.zero?

          scoped(scope)
            .recent
            .sum(:size)
        end

        def scoped(scope)
          populations
            .public_send(scope)
        end
      end
    end
  end
end
