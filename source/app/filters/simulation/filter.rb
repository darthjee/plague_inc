# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Filter < ::BaseFilter
    filter_by :name
    filter_by :status
  end
end