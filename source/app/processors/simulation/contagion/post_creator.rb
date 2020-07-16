# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PostCreator
      def initialize(instant)
        @instant = instant
      end

      def process
        Killer.new(instant).process
        Healer.new(instant).process

        instant.status = 'ready'

        ActiveRecord::Base.transaction do
          instant.save
        end
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :days_till_recovery, to: :contagion
      delegate :populations, to: :instant
    end
  end
end
