# frozen_string_literal: true

module Kiroshi
  class Filters
    class << self
      def filter_by(attribute, **options)
        @filter_configs ||= []
        @filter_configs << Filter.new(attribute, **options)
      end

      def filter_configs
        @filter_configs || []
      end
    end

    attr_reader :filters

    def initialize(filters = {})
      @filters = filters || {}
    end

    def apply(scope)
      self.class.filter_configs.each do |filter|
        scope = filter.apply(scope, filters)
      end

      scope
    end
  end
end
