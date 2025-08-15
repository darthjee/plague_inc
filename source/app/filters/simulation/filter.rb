# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Filter
    attr_reader :filters

    def initialize(filters = {})
      @filters = filters || {}
    end

    def apply(scope)
      scope = scope.where(name: filters[:name]) if filters[:name].present?
      scope = scope.where(status: filters[:status]) if filters[:status].present?
      scope
    end
  end
end