# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Creates a new instant to start processing
    class Initializer < ::Processor
      # @param instant [Instant] currently processed instant
      def initialize(instant)
        @instant = instant
      end

      # Creates a new instant.copying all not healthy populations
      #
      # @return [Instant] newly built and saved instant
      def process
        instant.status = Instant::PROCESSING

        new_instant.tap do
          build_populations
          save
        end
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :populations, to: :instant
      delegate :not_healthy, to: :populations

      def new_instant
        @new_instant ||= contagion.instants.build(
          day: instant.day + 1
        )
      end

      def build_populations
        not_healthy.map do |pop|
          Population::Builder.build(
            instant: new_instant,
            population: pop
          )
        end
      end

      def save
        ActiveRecord::Base.transaction do
          new_instant.save
          instant.save
        end
      end
    end
  end
end
