# frozen_string_literal: true

module Cacheable
  module ClassMethods
    def cache_for(klass)
      cache_factory.add_cache(klass)
    end

    def cache_factory
      @cache_factory ||= CacheStore::Factory.new
    end
  end
end
