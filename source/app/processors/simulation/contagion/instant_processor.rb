# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantProcessor
      def self.process(instant)
        new(instant).process
      end

      def process
        Contagion::Interactor.process(instant, new_instant)

        instant.status = Instant::PROCESSED
        finish_population

        ActiveRecord::Base.transaction do
          instant.save

          new_instant.save
        end

        new_instant
      end

      private

      attr_reader :instant

      def initialize(instant)
        @instant = instant
      end

      def finish_population
        instant.populations.healthy.each do |pop|
          new_pop = Population::Builder.build(
            instant: new_instant,
            population: pop,
            size: pop.remaining_size
          )
        end
      end

      def new_instant
        @new_instant ||= Initializer.process(instant)
      end
    end
  end
end
