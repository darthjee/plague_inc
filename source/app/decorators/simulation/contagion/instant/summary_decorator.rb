# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      # @author darthjee
      #
      # Exposes a summary of an instant
      class SummaryDecorator < Azeroth::Decorator
        expose :id
        expose :status
        expose :day

        expose :total

        expose :dead
        expose :dead_percentage
        expose :infected
        expose :infected_percentage
        expose :immune
        expose :immune_percentage
        expose :healthy
        expose :healthy_percentage

        def total
          @total ||= scoped_size(:all)
        end

        def dead
          @dead ||= scoped_size(:dead)
        end

        def infected
          @infected ||= scoped_size(:infected)
        end

        def immune
          @immune ||= scoped_size(:immune)
        end

        def healthy
          @healthy ||= scoped_size(:healthy)
        end

        def dead_percentage
          return 0 unless total.positive?
          dead.to_f / total
        end

        def infected_percentage
          return 0 unless total.positive?
          infected.to_f / total
        end

        def immune_percentage
          return 0 unless total.positive?
          immune.to_f / total
        end

        def healthy_percentage
          return 0 unless total.positive?
          healthy.to_f / total
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
