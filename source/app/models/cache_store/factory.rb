# frozen_string_literal: true

class CacheStore
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
