# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # process one instant
    #
    # an interaction is forced infecting
    # some members of healthy populations into
    # a new instant, after that, the remaining
    # healthy population is then copied into the
    # new instant
    class InstantProcessor
      def self.process(instant)
        new(instant).process
      end

      def process
        interact
        build_healthy
        save

        new_instant
      end

      private

      attr_reader :instant

      delegate :simulation, to: :contagion
      delegate :contagion, to: :instant

      def initialize(instant)
        @instant = instant
      end

      def interact
        Contagion::Interactor.process(instant, new_instant)

        instant.status = Instant::PROCESSED
      end

      def build_healthy
        healthy_populations.each do |pop|
          Population::Builder.build(
            instant: new_instant,
            population: pop,
            size: pop.remaining_size
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

      def new_instant
        @new_instant ||= find_or_create_instant
      end

      def healthy_populations
        instant.populations.healthy
      end

      def find_or_create_instant
        created_instant || Initializer.process(instant)
      end

      def created_instant
        instant.contagion.instants.created.last
      end
    end
  end
end
