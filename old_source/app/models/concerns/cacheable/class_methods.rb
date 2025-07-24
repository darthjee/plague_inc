# frozen_string_literal: true

module Cacheable
  # Class methods for adding cache on cacheable
  module ClassMethods
    def cache_for(klass)
      cache_factory.add_cache(klass)
    end

    def cache_factory
      @cache_factory ||= Cache::Factory.new
    end
  end
end
