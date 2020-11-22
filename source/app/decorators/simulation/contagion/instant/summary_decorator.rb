# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      # @author darthjee
      #
      # Exposes a summary of an instant
      class SummaryDecorator < Azeroth::Decorator
        class << self
          def expose_counts(state)
            send(:expose, state)
            send(:expose, "#{state}_percentage")

            Sinclair.new(self).tap do |builder|
              builder.add_method(state, cached: true) do
                scoped_size(state)
              end

              builder.add_method("#{state}_percentage") do
                return 0 unless total.positive?

                send(state).to_f / total
              end
            end.tap(&:build)
          end
        end

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
