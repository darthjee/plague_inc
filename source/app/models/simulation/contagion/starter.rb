# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Starter
      def initialize(simulation)
        @simulation = simulation
      end

      def process
        ActiveRecord::Base.transaction do
          @instant = instants.create(day: 0)

          contagion.groups.each do |group|
            build_populations(group)
          end
        end
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
        return if group.infected >= group.size
        instant.populations.create(
          group: group,
          behavior: group.behavior,
          size: group.size - group.infected
        )
      end

      def build_infected(group)
        return if group.infected.zero?
        instant.populations.create(
          group: group,
          behavior: group.behavior,
          size: group.infected,
          infected_days: 0
        )
      end
    end
  end
end
