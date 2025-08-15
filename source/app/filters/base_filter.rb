# frozen_string_literal: true

class BaseFilter
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

  def initialize(filters = {})
    @filters = filters || {}
  end

  def apply(scope)
    self.class.filter_attributes.each do |attribute|
      filter_value = filters[attribute]
      if filter_value.present?
        # scope = scope.where(attribute => filter_value)
        scope = scope.where("#{attribute} LIKE ?", "%#{filter_value}%")
      end
    end
    
    scope
  end
end