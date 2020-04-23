# frozen_string_literal: true

class Simulation < ApplicationRecord
  ALGORITHMS = %w[
    contagion
  ].freeze

  has_one :contagion

  validates_presence_of :name, :algorithm
  validates_inclusion_of :algorithm, in: ALGORITHMS

  def settings
    contagion
  end

  def settings=(settings)
    self.contagion = settings
  end
end
