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
          simulation.contagion.instants.each do |instant|
            instant.populations.destroy_all
            instant.destroy
          end
        end
      end

      private

      attr_reader :simulation_id, :day

      def simulation
        Simulation.find(simulation_id)
      end

      def new_status
        day > 1 ? :processed : :created
      end
    end
  end
end
