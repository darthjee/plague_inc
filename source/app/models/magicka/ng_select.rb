# frozen_string_literal: true

module Magicka
  class NgSelect < Magicka::Select
    with_attribute_locals :text_field, :reference_key
  end
end
