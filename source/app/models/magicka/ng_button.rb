# frozen_string_literal: true

module Magicka
  # Screen button element with angular attributes
  class NgButton < Magicka::Button
    with_attribute_locals :ng_hide, :ng_show
  end
end
