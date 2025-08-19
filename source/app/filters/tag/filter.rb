# frozen_string_literal: true

class Tag < ApplicationRecord
  class Filter < Kiroshi::Filters
    filter_by :name, match: :exact
  end
end
