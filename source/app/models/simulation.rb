# frozen_string_literal: true

require './app/models/simulation/builder'

class Simulation < ApplicationRecord
  ALGORITHMS = %w[
    contagion
  ].freeze

  ALLOWED_ATTRIBUTES = %i[name algorithm].freeze

  has_one :contagion

  validates_presence_of :name, :algorithm, :settings
  validates_inclusion_of :algorithm, in: ALGORITHMS
  validates_associated :settings

  def settings
    contagion
  end

  def settings=(settings)
    self.contagion = settings
  end
end
