# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InteractionStore
      def initialize(contagion_risk, healthy)
        @contagion_risk = contagion_risk
        @healthy        = healthy
      end

      def interact
        index = next_interaction
        interaction_map[index] += 1
        infect(index) if random_box < contagion_risk
      end

      def infected
        @infected ||= infection_map.size
      end

      def infection_map
        @infection_map ||= Hash.new(0)
      end

      private

      attr_reader :contagion_risk, :healthy

      def infect(index)
        infection_map[index] += 1
      end

      def next_interaction
        loop do
          index = random_box.person(healthy_size)
          return index if interaction_map[index] < healthy.behavior.interactions
        end
      end

      def healthy_size
        healthy.size - healthy.new_infections
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      def random_box
        @random_box ||= RandomBox.new
      end
    end
  end
end
