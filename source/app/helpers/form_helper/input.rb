# frozen_string_literal: true

module FormHelper
  class Input < Element
    def self.render(*args)
      new(*args).render
    end

    private

    attr_reader :placeholder

    def initialize(placeholder: nil, **args)
      super(**args)
      @placeholder = placeholder
    end

    def template
      'templates/forms/input'
    end

    def locals
      super.merge(placeholder: placeholder)
    end
  end
end
