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
      def self.process(contagion)
        new(contagion).process
      end

      def process
        contagion.groups.each do |group|
          build_populations(group)
        end

        instant.tap(&:save)
      end

      private

      attr_reader :contagion, :instant

      def initialize(contagion)
        @contagion = contagion
      end

      def instant
        @instant ||= instants.create(day: 0)
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
