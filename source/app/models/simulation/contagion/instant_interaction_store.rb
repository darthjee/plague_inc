# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class InstantInteractionStore
      def initialize(instant)
        @instant = instant
      end

      def interact
        next_interaction
        interaction_map[populations[0]] += 1
        populations[0].interactions -= 1
      end

      def interaction_map
        @interaction_map ||= Hash.new { 0 }
      end

      private

      attr_reader :instant

      delegate :populations, to: :instant

      def next_interaction
        random_box.interaction(max_interactions)
      end

      def max_interactions
        populations.map(&:interactions).sum
      end

      def random_box
        @random_box ||= RandomBox.instance
      end
    end
  end
end
