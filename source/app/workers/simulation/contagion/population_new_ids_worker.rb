# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PopulationNewIdsWorker
      include Sidekiq::Worker

      sidekiq_options queue: :super_critical

      def perform
        return unless Simulation::Contagion::Population.where(new_id: nil).any?
      end
    end
  end
end

