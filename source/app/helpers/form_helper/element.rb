# frozen_string_literal: true

module FormHelper
  class Element
    def self.render(*args)
      new(*args).render
    end

    def render
      renderer.render partial: template, locals: locals
    end

    private

    attr_reader :renderer, :field, :model

    def initialize(renderer:, field:, model: nil, label: nil)
      @renderer = renderer
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
