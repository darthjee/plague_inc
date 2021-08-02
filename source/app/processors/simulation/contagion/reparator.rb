# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Reparator
      include ::Processor
      include Contagion::Cacheable

      def self.check_and_fix_all
        check_all
        repair_all
      end

      def self.check_all
        Simulation::Contagion
          .eager_load(:groups)
          .eager_load(:simulation)
          .eager_load(:current_instant)
          .eager_load(current_instant: :populations)
          .where(simulations: { status: :finished, checked: false })
          .each do |c|
            current_size = c.current_instant.populations.map(&:size).sum
            size = c.groups.map(&:size).sum
            c.simulation.update(checked: current_size == size)
          end
      end

      def self.repair_all
        Simulation.eager_load(:contagion).eager_load(contagion: :groups).where(status: :finished, checked: false).map do |simulation|
            size = simulation.contagion.groups.map(&:size).sum
            day = simulation.contagion.instants.joins(:populations).group(:instant_id).order(:day).having("sum(size) <> ?",size).pluck(:day).first
          [simulation.id, day]
        end.select { |id, day| day }.each do|id, day|
          Simulation::Contagion::Reparator.process(id, day-1)
          Simulation::ProcessorWorker.perform_async(id)
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
