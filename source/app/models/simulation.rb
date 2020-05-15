# frozen_string_literal: true

class Simulation < ApplicationRecord
  ALGORITHMS = %w[
    contagion
  ].freeze

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

  def build_settings(attrs)
    case algorithm
    when 'contagion'
      build_contagion(attrs)
    end
  end
end
