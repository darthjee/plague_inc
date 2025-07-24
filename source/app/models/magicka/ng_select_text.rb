# frozen_string_literal: true

module Magicka
  # Element representing a special text that references
  # another list
  class NgSelectText < Magicka::Text
    with_attribute_locals :text_field, :options, :reference_key
  end
end
