# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Killer
      def initialize(instant)
        @instant = instant
      end

      def process
        populations
          .select(&:infected?)
          .select { |pop| pop.days >= days_till_start_death }
          .each do |population|
          Death.new(population, contagion).process
        end
      end

      private

      attr_reader :instant, :contagion

      delegate :contagion, to: :instant
      delegate :populations, to: :instant
      delegate :days_till_start_death, to: :contagion
    end
  end
end
