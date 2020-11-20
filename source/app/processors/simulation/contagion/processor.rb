# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Process a simulation
    #
    # When the simulation is new, then the first instant
    # will be created and pupulated
    #
    # when the simulation is already in process then
    # the presence of a processing instant indicates that
    # it's processing needs to be finished.
    #
    # The prsence of a ready instant means that a new instant
    # processing can begin
    class Processor
      include ::Processor
      include Contagion::Cacheable

      def process
        StatusKeeper.process(simulation) do
          PostCreator.process(instant, cache: cache)
        end

        instant
      end

      private

      attr_reader :contagion, :options
      delegate :instants, to: :contagion
      delegate :simulation, to: :contagion

      def initialize(contagion, options)
        @contagion = contagion
        @options   = options
      end

      def instant
        @instant ||= find_or_build_instant
      end

      def find_or_build_instant
        return process_ready_instant if any_ready?

        cached_created_instant || start_instant
      end

      def cached_created_instant
        return unless created_instant

        CacheWarmer.process(
          created_instant, cache: cache
        )
      end

      def created_instant
        @created_instant ||= instants.find_by(status: :created)
      end

      def start_instant
        Starter.process(contagion, cache: cache)
      end

      def process_ready_instant
        InstantProcessor.process(
          ready_instant, options, cache: cache
        )
      end

      def ready_instant
        @ready_instant ||= instants.find_by(status: %i[ready processing])
      end

      def any_ready?
        ready_instant.present?
      end
    end
  end
end
