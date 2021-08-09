# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorInitialWorker < ProcessorWorker
    sidekiq_options queue: :critical

    private

    def next_worker
      ProcessorWorker
    end
  end
end
