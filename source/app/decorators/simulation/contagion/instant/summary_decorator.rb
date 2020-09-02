# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      class SummaryDecorator < Azeroth::Decorator
        expose :total
        expose :dead
        expose :infected
        expose :immune
        expose :healthy

        def total
          scoped_size(:all)
        end

        def dead
          scoped_size(:dead)
        end

        def infected
          scoped_size(:infected)
        end

        def immune
          scoped_size(:immune)
        end

        def healthy
          scoped_size(:healthy)
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
