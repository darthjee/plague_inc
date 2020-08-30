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

      def process
        StatusKeeper.process(simulation) do
          PostCreator.process(instant)
        end
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
        return InstantProcessor.process(ready_instant) if any_ready?

        instants.find_by(status: :created) ||
          Starter.process(contagion)
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
