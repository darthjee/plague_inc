# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorCriticalWorker < ProcessorWorker
    sidekiq_options queue: :critical
  end
end
