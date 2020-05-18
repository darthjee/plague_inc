# frozen_string_literal: true

module FormHelper
  class Text < InputElement
    private

    attr_reader :placeholder
    default_value :template, 'templates/display/text'
  end
end

