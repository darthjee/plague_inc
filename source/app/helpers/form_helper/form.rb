module FormHelper
  class Form
    attr_reader :model

    def initialize(renderer, model)
      @renderer = renderer
      @model    = model
    end

    def input(field,
              model: self.model,
                        placeholder: nil,
                        label: field.to_s.capitalize.gsub(/_/, ' '))
      locals = {
        label: label,
        ng_errors: [model, :errors, field].join('.'),
        ng_model: [model, field].join('.'),
        model: model,
        field: field,
        placeholder: placeholder
      }

      render partial: 'templates/forms/input', locals: locals
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

