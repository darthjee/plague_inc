# frozen_string_literal: true

require 'concerns/cacheable/class_methods'

# Adds cache capability to a class
module Cacheable
  extend ActiveSupport::Concern

  def from_cache(key, id)
    cache.find(key, id)
  end

  def with_cache(object, key)
    cache.fetch_from(key, object)
  end

  private

  delegate :cache_factory, to: :class

  def cache
    @cache ||= cache_factory.build
  end
end
