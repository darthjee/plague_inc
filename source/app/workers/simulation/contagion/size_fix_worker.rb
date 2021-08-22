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

        return enqueue_first unless day
      end

      private

      attr_reader :simulation_id

      delegate :contagion, to: :simulation
      delegate :instants, to: :contagion

      def enqueue_first
        return unless instants.any?

        self.class.perform_async(simulation_id, instants.last.day)
      end

      def simulation
        @simulation ||= Simulation
          .eager_load(:contagion)
          .find(simulation_id)
      end
    end
  end
end

