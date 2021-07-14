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

      def fix_populations
        return unless instant
        instant.populations.dead.find_by(days: 0).destroy
        instant.populations.immune.find_by(days: 0).destroy
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
