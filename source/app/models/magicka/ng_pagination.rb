# frozen_string_literal: true

module Magicka
  # Screen button element with angular attributes
  class NgPagination < Magicka::Element
    template_folder 'templates/display'

    with_attribute_locals :pagination, :path_method, :options
    with_attributes :model, :field
    with_locals :pagination_object

    def pagination_object
      [model, field].join('.')
    end
  end
end
