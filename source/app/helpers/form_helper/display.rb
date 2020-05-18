# frozen_string_literal: true

module FormHelper
  class Display
    attr_reader :model

    def initialize(renderer, model)
      @renderer = renderer
      @model    = model
    end

    def input(field, model: self.model, **args)
      Text.render(renderer: renderer, field: field, model: model, **args)
    end

    def select(field, model: self.model, **args)
      Select.render(renderer: renderer, field: field, model: model, **args)
    end

    def button(**args)
      Button.render(renderer: renderer, **args)
    end

    def with_model(model)
      new_model = [self.model, model].join('.')

      yield Display.new(renderer, new_model)
    end

    private

    attr_reader :renderer

    delegate :render, to: :renderer
  end
end

