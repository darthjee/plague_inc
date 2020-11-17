# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Processor to be run after creation of an instant
    class PostCreator
      include ::Processor
      include Contagion::Cacheable

      # @param instant [Instant] instant being processed
      def initialize(instant, cache:)
        @instant = instant
        @cache   = cache
      end

      # Kills and heals populations after creation of instant
      def process
        Killer.process(instant, cache: cache)
        Healer.process(instant)
        populations.each(&:setup_interactions)

        finalize
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :days_till_recovery, to: :contagion
      delegate :populations, to: :instant
      delegate :simulation, to: :contagion

      def finalize
        instant.status = Instant::READY

        ActiveRecord::Base.transaction do
          instant.save
          simulation.touch
        end
      end
    end
  end
end
