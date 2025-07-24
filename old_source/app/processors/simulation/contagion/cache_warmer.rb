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
        populate_groups
        populate_behaviors

        warm_models

        instant
      end

      private

      def populate_groups
        groups.each do |group|
          cache.put(group)
        end
      end

      def populate_behaviors
        behaviors.each do |behavior|
          cache.put(behavior)
        end
      end

      def warm_models
        instant.populations.each do |population|
          with_cache(population, :group)
          with_cache(population, :behavior)
          with_cache(population.group, :behavior)
        end
      end

      attr_reader :instant
      delegate :contagion, to: :instant
      delegate :groups, :behaviors, to: :contagion
    end
  end
end
