# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Creates and populates first instant
    class Starter
      # Creates and populates firts instant
      #
      # Populations are created based on simulation
      # groups
      #
      # @param simulation [Simulation] simulation
      #   to be processed
      def self.process(simulation)
        new(simulation).process
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

      def initialize(simulation)
        @simulation = simulation
      end

      delegate :contagion, to: :simulation
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
