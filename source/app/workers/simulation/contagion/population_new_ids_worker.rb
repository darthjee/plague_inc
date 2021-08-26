# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class PopulationNewIdsWorker
      include Sidekiq::Worker

      sidekiq_options queue: :super_critical

      def perform
        return unless Simulation::Contagion::Population.where(new_id: nil).any?
        new_id = Simulation::Contagion::Population.maximum(:new_id) + 1
        Simulation::Contagion::Population.where(new_id: nil).limit(1).update_all(new_id: new_id)

        self.class.perform_async
      end
    end
  end
end

