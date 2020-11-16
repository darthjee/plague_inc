# frozen_string_literal: true

module Cacheable
  module ClassMethods
    def cache_for(klass)
      store = CacheStore.new(klass)
      cache_store[store.key] = store
    end

    # private

    def cache_store
      @cache_store ||= {}
    end
  end
end
