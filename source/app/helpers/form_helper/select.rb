# frozen_string_literal: true

module FormHelper
  class Select < Element
    private

    attr_reader :options
    default_value :template, 'templates/forms/select'

    def initialize(options:, **args)
      super(**args)
      @options = options
    end

    def locals
      super.merge(options: options)
    end
  end
end
