# frozen_string_literal: true

module FormHelper
  class InputElement < Element
    private

    attr_reader :field, :model

    def initialize(field:, model: nil, label: nil, **args)
      super(**args)

      @field = field
      @model = model
      @label = label
    end

    def label
      @label ||= field.to_s.capitalize.gsub(/_/, ' ')
    end

    def ng_model
      [model, field].join('.')
    end

    def ng_errors
      [model, :errors, field].join('.')
    end

    def locals
      {
        label: label,
        ng_errors: ng_errors,
        ng_model: [model, field].join('.'),
        field: field
      }
    end
  end
end
