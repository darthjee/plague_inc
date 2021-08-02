# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Reparator
      include ::Processor
      include Contagion::Cacheable

      class << self
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

      def initialize(simulation_id, day)
        @simulation_id = simulation_id
        @day = day
      end

      def process
        ActiveRecord::Base.transaction do
          simulation.update(status: new_status)
          delete_instants
          fix_populations
        end
      end

      private

      attr_reader :simulation_id, :day

      delegate :contagion, to: :simulation

      def simulation
        @simulation ||= Simulation.find(simulation_id)
      end

      def instant
        @instant ||= contagion.instants.find_by(day: day)
      end

      def previous_instant
        @previous_instant ||= contagion.instants.find_by(day: day - 1)
      end

      def fix_populations
        return unless instant

        destroy_populations
        rebuild_populations
        PostCreator.process(instant, cache: cache)
      end

      def destroy_populations
        instant.populations.dead.find_by(days: 0)&.destroy
        instant.populations.immune.find_by(days: 0)&.destroy
      end

      def rebuild_populations
        previous_instant.populations.healthy.each do |prev_pop|
          rebuild_population(prev_pop, :healthy)
          rebuild_infected_population(prev_pop)
        end
        previous_instant.populations.infected.each do |prev_pop|
          rebuild_population(prev_pop, :infected)
        end
      end

      def rebuild_population(prev_pop, state)
        healthy_pop = instant
                      .populations.where(state: state)
                      .find_or_initialize_by(
                        group: prev_pop.group,
                        days: prev_pop.days + 1
                      )

        healthy_pop.behavior ||= prev_pop.behavior
        healthy_pop.size = prev_pop.remaining_size
        healthy_pop.new_infections = 0
        healthy_pop.save
      end

      def rebuild_infected_population(prev_pop)
        infected_pop = instant
                       .populations.infected.where(days: 0)
                       .find_or_initialize_by(group: prev_pop.group, days: 0)

        infected_pop.size = prev_pop.new_infections
        infected_pop.new_infections = 0
        infected_pop.behavior ||= prev_pop.group.behavior
        infected_pop.save
      end

      def delete_instants
        instants_to_delete.each do |instant|
          instant.populations.destroy_all
          instant.destroy
        end
      end

      def instants_to_delete
        return contagion.instants if delete_all?

        contagion.instants.where('day > ?', day)
      end

      def new_status
        delete_all? ? :created : :processed
      end

      def delete_all?
        day <= 1
      end
    end
  end
end
