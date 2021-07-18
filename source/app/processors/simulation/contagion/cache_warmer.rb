# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    class CacheWarmer
      include ::Processor
      include Contagion::Cacheable

      def initialize(instant, cache:)
        @instant = instant
        @cache   = cache
      end

      def process
        groups.each do |group|
          cache.put(group)
        end

        behaviors.each do |behavior|
          cache.put(behavior)
        end

        instant.populations.each do |population|
          with_cache(population, :group)
          with_cache(population, :behavior)
          with_cache(population.group, :behavior)
        end

        instant
      end

      private

      attr_reader :instant
      delegate :contagion, to: :instant
      delegate :groups, :behaviors, to: :contagion
    end
  end
end
