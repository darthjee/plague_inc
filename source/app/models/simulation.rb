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
  has_and_belongs_to_many :tags

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

  def attach_tag(name)
    return if tags.map(&:name).include?(name.downcase)

    tags << Tag.for(name)
  end

  def add_tag(name)
    attach_tag(name)
    save
  end

  def processed?
    status == PROCESSED
  end

  def finished?
    status == FINISHED
  end

  def processing?
    status == PROCESSING
  end

  def processable?
    processing? && updated_at < Settings.processing_timeout.to_i.seconds.ago ||
      !processing?
  end

  def processable_in
    return 0 if processable?
    return Settings.processing_wait_time unless processing?

    updated_at - Settings.processing_timeout.to_i.seconds.ago
  end
end
