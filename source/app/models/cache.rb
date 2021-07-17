class Cache
  def initialize(configs)
    @configs = configs
  end

  def [](key)
    mapping[key]
  end

  def fetch_from(key, object)
    [key].fetch_from(object)
  end

  def find(key, id)
    [key].find(id)
  end

  private

  attr_reader :configs

  def mapping
    @mapping ||= build_mapping
  end

  def build_mapping
    configs.each_with_object({}) do |klass, hash|
      store = CacheStore.new(klass)
      hash[store.key.to_sym] = store
      hash[klass]            = store
    end
  end
end
