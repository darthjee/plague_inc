# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Processor to be run after creation of an instant
    class PostCreator < ::Processor
      # @param instant [Instant] instant being processed
      def initialize(instant)
        @instant = instant
      end

      # Kills and heals populations after creation of instant
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
    end
  end
end
