# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Filter
    class << self
      def filter_by(attribute)
        @filter_attributes ||= []
        @filter_attributes << attribute
      end

      def filter_attributes
        @filter_attributes || []
      end
    end

    attr_reader :filters

    filter_by :name
    filter_by :status

    def initialize(filters = {})
      @filters = filters || {}
    end

    def apply(scope)
      self.class.filter_attributes.each do |attribute|
        filter_value = filters[attribute]
        scope = scope.where(attribute => filter_value) if filter_value.present?
      end
      
      scope
    end
  end
end