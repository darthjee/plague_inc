# frozen_string_literal: true

module Kiroshi
  class Filter
    attr_reader :attribute, :options

    def initialize(attribute, **options)
      @attribute = attribute
      @options = options
    end

    def apply(scope, filters)
      filter_value = filters[attribute]
      return scope unless filter_value.present?

      case options[:match]
      when :like
        scope.where("#{attribute} LIKE ?", "%#{filter_value}%")
      else # :exact (default)
        scope.where(attribute => filter_value)
      end
    end
  end
end