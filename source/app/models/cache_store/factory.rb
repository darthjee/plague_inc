# frozen_string_literal: true

class CacheStore
  # Configure a set of CacheStore and builds it on demand
  #
  # @example
  #   factory = CacheStore.new
  #   factory.add_cache(Simulation::Contagion::Group)
  #   factory.add_cache(Simulation::Contagion::Behavior)
  #
  #   factory.build # returns
  #                 #  {
  #                 #    group: <CacheStore klass=Group>
  #                 #    behavior: <CacheStore klass=Behavior>
  #                 #  }
  class Factory
    def add_cache(klass)
      configs << klass
    end

    def build
      configs.each_with_object({}) do |klass, hash|
        store = CacheStore.new(klass)
        hash[store.key.to_sym] = store
      end
    end

    private

    def configs
      @configs ||= Set.new
    end
  end
end
