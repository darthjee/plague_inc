# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Runs all interactions of an instant
    #
    # All infected populations go through interactions
    # with other populations generating new infected populations
    # in the new_instant
    class Interactor
      include ::Processor

      def process
        interact

        instant.status = Instant::PROCESSED

        save
      end

      private

      attr_reader :instant, :new_instant, :options

      delegate :simulation, to: :contagion
      delegate :contagion, to: :instant

      # @param instant {Instant} Instant being processed
      # @param new_instant [Instant] instant where the new
      #   infected population will be created
      def initialize(instant, new_instant, options = nil)
        @instant     = instant
        @new_instant = new_instant
        @options     = options
      end

      def interact
        infected_populations.each do |population|
          InfectedInteractor.process(
            population,
            instant,
            new_instant,
            options
          )
        end
      end

      def save
        ActiveRecord::Base.transaction do
          instant.save
          new_instant.save
          simulation.touch
        end
      end

      def infected_populations
        instant.populations
               .select(&:infected?)
               .select(&:interactions?)
      end
    end
  end
end
