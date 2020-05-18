# frozen_string_literal: true

module FormHelper
  class Button < Element
    private

    attr_reader :text, :ng_click, :ng_disabled, :classes
    default_value :template, 'templates/forms/button'

    def initialize(text:, ng_click: nil, ng_disabled: nil, classes: nil, **args)
      super(**args)

      @text = text
      @ng_click = ng_click
      @ng_disabled = ng_disabled
      @classes = classes
    end

    def locals
      {
        ng_click: ng_click,
        ng_disabled: ng_disabled,
        classes: classes,
        text: text
      }
    end
  end
end
