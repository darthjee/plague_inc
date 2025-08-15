# frozen_string_literal: true

module Kiroshi
  class Filter
    attr_reader :attribute, :match

    def initialize(attribute, match: :exact)
      @attribute = attribute
      @match = match
    end

    def apply(scope, filters)
      filter_value = filters[attribute]
      return scope unless filter_value.present?

      case match
      when :like
        scope.where("#{attribute} LIKE ?", "%#{filter_value}%")
      else # :exact (default)
        scope.where(attribute => filter_value)
      end
    end
  end
end