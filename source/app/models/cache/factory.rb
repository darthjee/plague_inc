# frozen_string_literal: true

class Cache
  class Factory
    def add_cache(klass)
      configs << klass
    end

    def build
      Cache.new(configs)
    end

    private

    def configs
      @configs ||= Set.new
    end
  end
end
