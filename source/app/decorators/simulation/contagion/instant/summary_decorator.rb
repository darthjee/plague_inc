# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Instant < ApplicationRecord
      class SummaryDecorator < Azeroth::Decorator
        expose :total

        def total
          populations.sum(:size)
        end
      end
    end
  end
end
