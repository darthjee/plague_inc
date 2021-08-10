# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Enqueue
    include ::Processor

    def process
      schedule_critical
      schedule_non_critical
      schedule_created
    end

    private

    def schedule_critical
      critical_ids.each do |id|
        Simulation::ProcessorCriticalWorker.perform_async(id)
      end
    end

    def schedule_non_critical
      non_critical_ids.each do |id|
        Simulation::ProcessorWorker.perform_async(id)
      end
    end

    def schedule_created
      created.pluck(:id).each do |id|
        Simulation::ProcessorInitialWorker.perform_async(id)
      end
    end

    def scope
      Simulation.where.not(status: %i[finished created])
    end

    def created
      Simulation.where(status: :created)
    end

    def total
      @total ||= scope.count
    end

    def half
      total / 2
    end

    def non_critical_ids
      scope.where.not(id: critical_ids).pluck(:id)
    end

    def critical_ids
      @critical_ids ||= scope.limit(half).pluck(:id)
    end
  end
end
