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
        build_healthy(group)
        build_infected(group)
      end

      def build_healthy(group)
        return unless group.any_healthy?

        instant.populations.build(
          group: group,
          behavior: group.behavior,
          size: group.healthy
        )
      end

      def build_infected(group)
        return unless group.any_infected?

        instant.populations.build(
          group: group,
          behavior: group.behavior,
          size: group.infected,
          infected_days: 0
        )
      end
    end
  end
end
