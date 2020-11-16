class CacheStore
  class Factory
    def add_cache(klass)
      configs << klass
    end

    def build
      configs.inject({}) do |hash, klass|
        store = CacheStore.new(klass)
        hash[store.key.to_sym] = store
        hash
      end
    end

    private

    def configs
      @configs ||= Set.new
    end
  end
end

