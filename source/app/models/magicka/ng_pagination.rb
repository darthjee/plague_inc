# frozen_string_literal: true

module Magicka
  # Screen button element with angular attributes
  class NgPagination < Magicka::Element
    template_folder 'templates/display'

    with_attribute_locals :pagination
    with_attribute_locals :path_method
    with_attribute_locals :options
  end
end
