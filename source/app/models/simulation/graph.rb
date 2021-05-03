# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    has_many :plots

    validates :name,
              presence: true,
              length: { maximum: 255 }
  end
end
