# frozen_string_literal: true

require './app/processors/simulation/builder'

# @author darthjee
#
# Simulation class/model
class Simulation < ApplicationRecord
  ALGORITHMS = %w[
    contagion
  ].freeze

  CREATED = 'created'
  PROCESSING = 'processing'
  PROCESSED = 'processed'
  FINISHED = 'finished'

  ALLOWED_ATTRIBUTES = %i[name algorithm].freeze
  STATUSES = [
    CREATED, PROCESSING, PROCESSED, FINISHED
  ].freeze

  has_one :contagion

  validates_presence_of :algorithm, :settings, :status
  validates_inclusion_of :algorithm, in: ALGORITHMS
  validates_inclusion_of :status, in: STATUSES
  validates_associated :settings
  validates :name,
            presence: true,
            length: { maximum: 255 }

  def settings
    contagion
  end

  def settings=(settings)
    self.contagion = settings
  end
end
