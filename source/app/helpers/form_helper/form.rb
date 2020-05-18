module FormHelper
  class Form
    def initialize(renderer)
      @renderer = renderer
    end

    def input(model, field,
                        placeholder: nil,
                        label: field.to_s.capitalize.gsub(/_/, ' '))
      Form.new(self)
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

    def select(model, field, label: field.capitalize, options: [])
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

    private

    attr_reader :renderer

    delegate :render, to: :renderer
  end
end

