# frozen_string_literal: true

require 'concerns/cacheable/class_methods'

module Cacheable
  extend ActiveSupport::Concern

  def from_cache(key, id)
    cache_store(key).find(id)
  end

  def with_cache(object, key)
    cache_store(key).fetch_from(object)
  end

  private

  delegate :cache_factory, to: :class

  def cache_store(key)
    cache_stores[key]
  end

  def cache_stores
    @cache_stores ||= cache_factory.build
  end
end
