# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class SizeFixWorker
      include Sidekiq::Worker

      sidekiq_options queue: :super_critical

      def self.enqueue_all
        Simulation.contagion.pluck(:id).each do |id|
          perform_async(id)
        end
      end

      def perform(simulation_id, day = nil)
        @simulation_id = simulation_id
        @day = day

        return enqueue_first unless day

        fix_populations
        enqueue_next
      end

      private

      attr_reader :simulation_id, :day

      delegate :contagion, to: :simulation
      delegate :instants, to: :contagion

      def fix_populations
        instant.populations.healthy.empty.each do |pop|
          next unless delete?(pop)
          pop.delete
        end
      end

      def delete?(population)
        previous_populations.where(
          state: population.state,
          group: population.group,
          size: 0
        ).any?
      end

      def enqueue_first
        return unless instants.any?
        return if instants.last.day.zero?

        self.class.perform_async(simulation_id, instants.last.day)
      end

      def enqueue_next
        return if day <= 1

        self.class.perform_async(simulation_id, day - 1)
      end

      def simulation
        @simulation ||= Simulation
          .eager_load(:contagion)
          .find(simulation_id)
      end

      def instant
        @instant ||= instants.find_by(day: day)
      end

      def previous_instant
        @previous_instant ||= instants.find_by(day: day - 1)
      end

      def previous_populations
        @previous_populations ||= previous_instant.populations
      end
    end
  end
end

