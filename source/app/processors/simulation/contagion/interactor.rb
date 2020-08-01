# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Interactor
      include ::Processor

      def process
        instant.status = Instant::PROCESSED
        new_instant.status = Instant::READY

        InfectedInteractor.process(
          instant.populations.select(&:infected?).first,
          instant,
          new_instant
        )

        ActiveRecord::Base.transaction do
          instant.save
          new_instant.save
        end
      end

      private

      attr_reader :instant, :new_instant

      def initialize(instant, new_instant)
        @instant     = instant
        @new_instant = new_instant
      end
    end
  end
end
