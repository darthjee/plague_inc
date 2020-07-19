# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Starter
      def self.process(contagion)
        new(contagion).process
      end

      def process
        @instant = instants.create(day: 0)

        contagion.groups.each do |group|
          build_populations(group)
        end

        instant.save
      end

      private

      attr_reader :contagion, :instant

      def initialize(contagion)
        @contagion = contagion
      end

      delegate :instants, to: :contagion
      delegate :populations, to: :instant

      def build_populations(group)
        build(group, :healthy)
        build(group, :infected)
      end

      def build(group, state)
        return unless group.public_send("any_#{state}?")

        Population::Builder.build(
          instant: instant,
          group: group,
          state: state
        )
      end
    end
  end
end
