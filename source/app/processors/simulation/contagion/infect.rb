# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Infect
      def self.process(instant, infected, healthy, interactions)
        new(instant, infected, healthy, interactions).process
      end

      def process
        healthy.interactions = 0
        Population::Builder.build(
          instant: instant,
          group: healthy.group,
          behavior: healthy.behavior,
          state: Population::INFECTED
        )
      end

      private

      attr_reader :instant, :infected, :healthy, :interactions

      def initialize(instant, infected, healthy, interactions)
        @instant      = instant
        @infected     = infected
        @healthy      = healthy
        @interactions = interactions
      end

      def random_box
        @random_box ||= RandomBox.new
      end
    end
  end
end
