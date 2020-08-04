# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
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
        end
      end

      def new_instant
        @new_instant ||= Initializer.process(instant)
      end

      def healthy_populations
        instant.populations.healthy
      end
    end
  end
end
