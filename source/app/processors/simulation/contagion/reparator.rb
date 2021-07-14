# frozen_string_literal: true

require './app/processors/simulation/contagion/population/builder'

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Reparator
      include ::Processor

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
        instant.populations.dead.find_by(days: 0).destroy
        instant.populations.immune.find_by(days: 0).destroy
        fix_population(:healthy)
        PostCreator.process(instant, cache: CacheStore::Factory.new)
      end

      def fix_population(state)
        previous_instant.populations.where(state: state, days: 0).each do |prev_pop|
          pop = instant.populations.where(state: state, days: 0)
            .find_or_initialize_by(
              group: prev_pop.group, days: 0, behavior: prev_pop.behavior
            )

          pop.size = prev_pop.remaining_size
          pop.new_infections = 0
          pop.save
        end
      end

      def delete_instants
        instants_to_delete.each do |instant|
          instant.populations.destroy_all
          instant.destroy
        end
      end

      def instants_to_delete
        return contagion.instants if delete_all?
        contagion.instants.where("day > ?", day)
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
