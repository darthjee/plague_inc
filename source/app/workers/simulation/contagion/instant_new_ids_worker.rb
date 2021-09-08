# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantNewIdsWorker
      include Sidekiq::Worker

      sidekiq_options queue: :super_critical

      attr_reader :id

      def self.enqueue_all
        Simulation::Contagion::Instant.pluck(:id).each do |id|
          self.perform_async(id)
        end
      end

      def perform(id)
        @id = id

        if first_population
          instant.population.update_all(new_instant_id: instant.new_id)
        end
      end
      
      def first_population
        @first_population ||= Simulation::Contagion::Population.find_by(new_instant_id: nil, instant_id: id)
      end
      
      def instant
        @instant ||= first_population.instant
      end
    end
  end
end
