# frozen_string_literal: true

module FormHelper
  class Select < Element
    private

    attr_reader :options

    def initialize(options:, **args)
      super(**args)
      @options = options
    end

    def template
      'templates/forms/select'
    end

    def locals
      super.merge(options: options)
    end
  end
end
