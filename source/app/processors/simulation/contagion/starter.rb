# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # @author darthjee
    #
    # Creates and populates first instant
    class Starter
      include ::Processor
      # @param contagion [Contagion] contagion
      #   to be processed
      def initialize(contagion)
        @contagion = contagion
      end

      # Creates and populates firts instant
      #
      # Populations are created based on contagion
      # groups
      def process
        contagion.groups.each do |group|
          build_populations(group)
        end

        ActiveRecord::Base.transaction do
          simulation.touch
          instant.tap(&:save)
        end
      end

      private

      attr_reader :contagion

      delegate :simulation, to: :contagion
      delegate :instants, to: :contagion
      delegate :populations, to: :instant

      def instant
        @instant ||= instants.create(day: 0)
      end

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
