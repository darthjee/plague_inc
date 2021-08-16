# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'
require './app/processors/simulation/contagion/reparator/class_methods'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Reparator
      class << self
        include Reparator::ClassMethods
      end

      include ::Processor
      include Contagion::Cacheable

      def initialize(simulation_id, day, transaction: true)
        @simulation_id = simulation_id
        @day           = day
        @transaction   = transaction
      end

      def process
        return fix unless transaction?
        ActiveRecord::Base.transaction { fix }
      end

      private

      attr_reader :simulation_id, :day

      delegate :contagion, to: :simulation

      def fix
        simulation.update(status: Simulation::FIXING)
        delete_instants
        fix_populations
        simulation.update(status: new_status)
      end

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

      def transaction?
        @transaction
      end
    end
  end
end
