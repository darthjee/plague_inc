# frozen_string_literal: true

module FormHelper
  class Select
    def self.render(*args)
      new(*args).render
    end

    def render
      renderer.render partial: 'templates/forms/select', locals: locals
    end

    private

    attr_reader :renderer, :field, :model, :options

    def initialize(renderer, field, model: nil, label: nil, options: nil)
      @renderer = renderer
      @field = field
      @model = model
      @label = label
      @options = options
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
        field: field,
        options: options
      }
    end
  end
end

