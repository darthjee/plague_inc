# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Reparator
      module ClassMethods
        def check_and_fix_all
          check_all
          repair_all
        end

        def check_all
          simulations_to_check.each { |simulation| check(simulation) }
        end

        def repair_all
          broken_simulations_information.each do |id, day|
            Simulation::Contagion::Reparator.process(id, day)
            Simulation::ProcessorWorker.perform_async(id)
          end
        end

        private

        def check(simulation)
          contagion = simulation.contagion
          current_size = contagion.current_instant.populations.map(&:size).sum
          size = contagion.groups.map(&:size).sum
          contagion.simulation.update(checked: current_size == size)
        end

        def simulations_to_check
          scoped_simulations
            .eager_load(contagion: :current_instant)
            .eager_load(contagion: { current_instant: :populations })
        end

        def broken_simulations_information
          scoped_simulations.map do |simulation|
            broken_simulation_information(simulation)
          end.compact
        end

        def broken_simulation_information(simulation)
          size = simulation.contagion.groups.map(&:size).sum
          day = broken_day(simulation.contagion.instants, size)
          return unless day

          [simulation.id, day - 1]
        end

        def broken_day(instants, size)
          instants
            .joins(:populations)
            .group(:instant_id)
            .order(:day)
            .having('sum(size) <> ?', size)
            .pluck(:day)
            .first
        end

        def scoped_simulations
          Simulation
            .eager_load(:contagion)
            .eager_load(contagion: :groups)
            .where(status: :finished, checked: false)
        end
      end
    end
  end
end
