# frozen_string_literal: true

class Cache
  # Holds all cache for one specific class
  #
  # @example
  #   store = CacheStore.new(Simulation)
  #   store.find(1) # returns <Simulation id=1>
  class Store
    # @param klass [Class<ActiveRecord::Base>]
    #   class to be cached
    def initialize(klass)
      @klass = klass
    end

    def find(id)
      store[id]
    end

    def fetch_from(object)
      store[object.public_send(id_key)].tap do |value|
        object.public_send("#{key}=", value)
      end
    end

    def key
      @key ||= klass.name.gsub(/.*::/, '').underscore
    end

    def put(value)
      store[value.id] = value
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
end
