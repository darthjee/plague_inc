# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class Processor
      def self.process(contagion)
        new(contagion).process
      end

      def process
        PostCreator.process(instant)
      end

      private

      attr_reader :contagion
      delegate :instants, to: :contagion

      def initialize(contagion)
        @contagion = contagion
      end

      def instant
        @instant ||= begin
                       instants.find_by(status: :created) ||
                         Starter.process(contagion)
                     end
      end
    end
  end
end
