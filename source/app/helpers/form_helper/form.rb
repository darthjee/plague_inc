# frozen_string_literal: true

module FormHelper
  class Form
    attr_reader :model

    def initialize(renderer, model)
      @renderer = renderer
      @model    = model
    end

    def input(field, model: self.model, **args)
      Input.render(renderer, field, model: model, **args)
    end

    def select(field, model: self.model, label: field.capitalize, options: [])
      locals = {
        label: label,
        ng_errors: [model, :errors, field].join('.'),
        ng_model: [model, field].join('.'),
        model: model,
        field: field,
        options: options
      }

      render partial: 'templates/forms/select', locals: locals
    end

    def with_model(model)
      new_model = [self.model, model].join('.')

      yield Form.new(renderer, new_model)
    end

    private

    attr_reader :renderer

    delegate :render, to: :renderer
  end
end
