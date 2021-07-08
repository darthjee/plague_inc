# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorWorker
    include Sidekiq::Worker
    def perform(id)
      simulation = Simulation.find(id)
      Processor.process(simulation, times: 1)

      return if simulation.finished?
      self.class.perform_async(id)
    end
  end
end
