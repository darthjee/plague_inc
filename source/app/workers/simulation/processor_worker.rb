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

      Processor.process(simulation, times: 1)

      return if simulation.finished?

      self.class.perform_async(id)
    end
  end
end
