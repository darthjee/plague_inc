# frozen_string_literal: true

class SimulationsTag < ApplicationRecord
  belongs_to :simulation
  belongs_to :tag
end
