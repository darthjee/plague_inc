# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorWorker
    include Sidekiq::Worker
    def perform(id)
      simulation = Simulation
                   .eager_load(:contagion)
                   .eager_load(contagion: :groups)
                   .eager_load(contagion: :behaviors)
                   .find(id)

      Simulation::Processor.process(simulation, times: 1)

      return if simulation.finished?

      next_worker.perform_async(id)
    end

    def next_worker
      self.class
    end
  end
end
