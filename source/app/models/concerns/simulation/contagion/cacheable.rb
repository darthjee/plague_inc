# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    # Add cache on immutable objects for contagion
    module Cacheable
      extend ActiveSupport::Concern

      included do
        include ::Cacheable

        cache_for(Contagion::Group)
        cache_for(Contagion::Behavior)
      end

      private

      attr_writer :cache
    end
  end
end
