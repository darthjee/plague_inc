# frozen_string_literal: true

class Simulation < ApplicationRecord
  # @author darthjee
  #
  # Model for contagion type simulation
  class Contagion < ApplicationRecord
    ALLOWED_ATTRIBUTES = %i[
      lethality
      days_till_recovery
      days_till_sympthoms
      days_till_start_death
      days_till_contagion
    ].freeze

    belongs_to :simulation
    has_many :groups
    has_many :behaviors
    has_many :instants, -> { order(:day) }
    has_one :current_instant,
            -> { where(status: %i[created ready]) },
            class_name: 'Simulation::Contagion::Instant'

    validates_presence_of :simulation, :groups, :behaviors

    validates :lethality,
              presence: true,
              inclusion: { in: (0.0..1.0) }
    validates :days_till_recovery,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              }
    validates :days_till_sympthoms,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              }
    validates :days_till_start_death,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              }
    validates :days_till_contagion,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              }
    validates :days_till_contagion,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              }

    validates :days_till_immunization_end,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true
              },
              allow_nil: true

    validate :validate_days_till_sympthoms
    validate :validate_days_till_start_death
    validate :validate_days_till_contagion

    def process(options)
      Contagion::Processor.process(self, options)
    end

    def immunization_ends?
      days_till_immunization_end.present?
    end

    private

    def validate_days_till_sympthoms
      validate_against_recovery(
        :days_till_sympthoms,
        days_till_sympthoms
      )
    end

    def validate_days_till_start_death
      validate_against_recovery(
        :days_till_start_death,
        days_till_start_death
      )
    end

    def validate_days_till_contagion
      validate_against_recovery(
        :days_till_contagion,
        days_till_contagion
      )
    end

    def validate_against_recovery(key, days)
      return unless days_till_recovery
      return unless days_till_recovery < days.to_i

      errors.add(
        key,
        'cannot be greater than days to recovery'
      )
    end
  end
end
