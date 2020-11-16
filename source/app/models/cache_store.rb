class CacheStore
  def initialize(klass)
    @klass = klass
  end

  def find(id)
    store[id]
  end

  def fetch_from(object)
    store[object.public_send(id_key)]
  end

  private

  attr_reader :klass

  def store
    @store ||= Hash.new do |hash, id|
      hash[id] = klass.find(id)
    end
  end

  def key
    @key ||= klass.name.gsub(/.*::/,'').underscore
  end

  def id_key
    @id_key ||= "#{key}_id"
  end
end
