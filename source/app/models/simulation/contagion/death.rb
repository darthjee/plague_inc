# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Death
      def initialize(population, contagion)
        @population = population
        @contagion  = contagion
      end

      def process
        population.size = new_size
      end

      private

      attr_reader :population, :contagion
      delegate :lethality, to: :contagion

      def killed
        population.size.times.inject(0) do |total, _|
          lethality == 0 ? total : total + 1
        end
      end

      def new_size
        @new_size ||= population.size - killed
      end
    end
  end
end
