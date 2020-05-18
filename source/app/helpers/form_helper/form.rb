# frozen_string_literal: true

module FormHelper
  class Form
    attr_reader :model

    def initialize(renderer, model)
      @renderer = renderer
      @model    = model
    end

    def input(field, model: self.model, **args)
      Input.render(renderer: renderer, field: field, model: model, **args)
    end

    def select(field, model: self.model, **args)
      Select.render(renderer: renderer, field: field, model: model, **args)
    end

    def button(ng_click:, ng_disabled:, classes:)
      render partial: 'templates/forms/button', locals: {
        ng_click: ng_click,
        ng_disabled: ng_disabled,
        classes: classes,
      }
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
