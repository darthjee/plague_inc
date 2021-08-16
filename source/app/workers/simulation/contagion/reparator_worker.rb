# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class ReparatorWorker
      include Sidekiq::Worker

      sidekiq_options queue: :critical

      def perform(simulation_id, day)
        Reparator.process(simulation_id, day, transaction: false)
      end
    end
  end
end
