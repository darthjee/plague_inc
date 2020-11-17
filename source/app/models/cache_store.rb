# frozen_string_literal: true

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

  def key
    @key ||= klass.name.gsub(/.*::/, '').underscore
  end

  def ==(other)
    return false unless other.is_a? self.class

    klass == other.klass
  end

  protected

  attr_reader :klass

  private

  def store
    @store ||= Hash.new do |hash, id|
      hash[id] = klass.find(id)
    end
  end

  def id_key
    @id_key ||= "#{key}_id"
  end
end
