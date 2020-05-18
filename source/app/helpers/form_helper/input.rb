# frozen_string_literal: true

module FormHelper
  class Input < Element
    def self.render(*args)
      new(*args).render
    end

    private

    attr_reader :placeholder
    default_value :template, 'templates/forms/input'

    def initialize(placeholder: nil, **args)
      super(**args)
      @placeholder = placeholder
    end

    def locals
      super.merge(placeholder: placeholder)
    end
  end
end
