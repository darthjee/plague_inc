# frozen_string_literal: true

class Simulation < ApplicationRecord
  class ProcessorInitialWorker < ProcessorWorker
    sidekiq_options queue: :critical
  end
end

