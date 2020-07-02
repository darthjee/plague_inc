# frozen_string_literal: true

module Magicka
  class NgSelectText < Magicka::Text
    with_attribute_locals :text_field, :options, :reference_key
  end
end
