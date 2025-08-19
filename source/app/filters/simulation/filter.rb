# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Filter < Kiroshi::Filters
    filter_by :name, match: :like
    filter_by :status
    filter_by :tag_name, column: :name, table: :tags
  end
end
