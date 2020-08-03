# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Interactor
      include ::Processor

      def process
        interact

        instant.status = Instant::PROCESSED

        save
      end

      private

      attr_reader :instant, :new_instant

      def initialize(instant, new_instant)
        @instant     = instant
        @new_instant = new_instant
      end

      def interact
        infected_populations.each do |population|
          InfectedInteractor.process(
            population,
            instant,
            new_instant
          )
        end
      end

      def save
        ActiveRecord::Base.transaction do
          instant.save
          new_instant.save
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
