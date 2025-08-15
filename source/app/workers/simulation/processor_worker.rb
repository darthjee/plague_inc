# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorWorker
    include Sidekiq::Worker

    attr_reader :id

    def perform(id)
      return unless process?

      @id = id

      Simulation::Processor.process(simulation, times: 1)

      return if finished?

      next_worker.perform_async(id)
    end

    private

    delegate :finished?, to: :simulation

    def process?
      Settings.background_worker
    end

    def simulation
      @simulation ||= Simulation
                      .eager_load(:contagion)
                      .eager_load(contagion: :groups)
                      .eager_load(contagion: :behaviors)
                      .find(id)
    end

    def next_worker
      self.class
    end
  end
end
