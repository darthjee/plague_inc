# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Filter < Kiroshi::Filters
    filter_by :name
    filter_by :status
  end
end
