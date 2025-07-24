# frozen_string_literal: true

module Magicka
  class NgPagination < Magicka::Element
    template_folder 'templates/display'

    with_attribute_locals :path_method, :options
    with_attributes :model, :field
    with_locals :pagination, :current_page, :total_pages
    with_locals :per_page, :previous_page, :next_page
    with_locals :pages_list

    def pagination
      [model, field].join('.')
    end

    def current_page
      [pagination, 'page'].join('.')
    end

    def total_pages
      [pagination, 'pages'].join('.')
    end

    def pages_list
      [pagination, 'pagination'].join('.')
    end

    def options
      @options ||= {}
    end

    def previous_page
      "{{ #{pagination}.page - 1 }}"
    end

    def next_page
      "{{ #{pagination}.page + 1 }}"
    end

    def per_page
      "{{ #{pagination}.perPage }}"
    end
  end
end
