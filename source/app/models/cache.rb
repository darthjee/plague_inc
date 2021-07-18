# frozen_string_literal: true

class Cache
  delegate :empty?, to: :configs

  def initialize(configs)
    @configs = configs
  end

  def fetch_from(key, object)
    self[key].fetch_from(object)
  end

  def find(key, id)
    self[key].find(id)
  end

  def put(value)
    self[value.class].put(value)
  end

  def ==(other)
    return false unless other.is_a? self.class

    configs == other.configs
  end

  protected

  attr_reader :configs

  private

  def [](key)
    mapping[key]
  end

  def mapping
    @mapping ||= build_mapping
  end

  def build_mapping
    configs.each_with_object({}) do |klass, hash|
      store = Cache::Store.new(klass)
      hash[store.key.to_sym] = store
      hash[klass]            = store
    end
  end
end
