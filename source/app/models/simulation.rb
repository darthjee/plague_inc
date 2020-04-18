# frozen_string_literal: true

class Simulation < ApplicationRecord
  ALGORITHMS = %w[
    contagion
  ].freeze

  validates_presence_of :name, :algorithm
  validates_inclusion_of :algorithm, in: ALGORITHMS
end
