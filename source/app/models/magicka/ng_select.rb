# frozen_string_literal: true

module Magicka
  # Element representing a special select that references
  # another list
  class NgSelect < Magicka::Select
    with_attribute_locals :text_field, :reference_key
  end
end
