# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PostCreator
      def initialize(instant)
        @instant = instant
      end

      def process
        Killer.new(instant, contagion).process


        populations.select do |pop|
          pop.infected? && pop.days >= days_till_recovery
        end.each do |pop|
          pop.state = Population::IMMUNE
        end

        instant.save
      end

      private

      attr_reader :instant

      delegate :contagion, to: :instant
      delegate :days_till_recovery, to: :contagion
      delegate :populations, to: :instant
    end
  end
end
