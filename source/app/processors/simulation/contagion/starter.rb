# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Starter
      def initialize(simulation)
        @simulation = simulation
      end

      def process
        @instant = instants.create(day: 0)

        contagion.groups.each do |group|
          build_populations(group)
        end

        instant.save
      end

      private

      attr_reader :simulation, :instant

      delegate :contagion, to: :simulation
      delegate :instants, to: :contagion
      delegate :populations, to: :instant

      def build_populations(group)
        build(group, :healthy)
        build(group, :infected)
      end

      def build(group, type)
        return unless group.public_send("any_#{type}?")

        Population::Builder.build(
          instant: instant,
          group: group,
          type: type
        )
      end
    end
  end
end
