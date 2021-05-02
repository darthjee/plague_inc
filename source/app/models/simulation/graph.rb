# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    validates :name,
              presence: true,
              length: { maximum: 255 }
  end
end
