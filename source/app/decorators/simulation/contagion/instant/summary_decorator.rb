# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      class SummaryDecorator < Azeroth::Decorator
        expose :total
        expose :dead

        def total
          scoped_size(:all)
        end

        def dead
          scoped_size(:dead)
        end

        def immune
          scoped_size(:immune)
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
