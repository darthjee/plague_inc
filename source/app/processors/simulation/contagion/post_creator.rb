# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Processor to be run after creation of an instant
    class PostCreator
      # Kills and heals populations after creation of instant
      #
      # @param instant [Instant] instant being processed
      def self.process(instant)
        new(instant).process
      end

      def process
        Killer.process(instant)
        Healer.process(instant)

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

      def initialize(instant)
        @instant = instant
      end
    end
  end
end
