# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    ALLOWED_ATTRIBUTES = %i[
      lethality
      days_till_recovery
      days_till_sympthoms
      days_till_start_death
    ].freeze

    belongs_to :simulation
    has_many :groups

    validates_presence_of :simulation, :groups

    validates :lethality,
              presence: true,
              inclusion: { in: (0.0..1.0) }
    validates :days_till_recovery,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }
    validates :days_till_sympthoms,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }
    validates :days_till_start_death,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }

    validate :validate_days_till_sympthoms
    validate :validate_days_till_start_death

    private

    def validate_days_till_sympthoms
      return unless days_till_recovery
      return unless days_till_recovery < days_till_sympthoms.to_i

      errors.add(
        :days_till_sympthoms,
        'cannot be greater than days to recovery'
      )
    end

    def validate_days_till_start_death
      return unless days_till_recovery
      return unless days_till_recovery < days_till_start_death.to_i

      errors.add(
        :days_till_start_death,
        'cannot be greater than days to recovery'
      )
    end
  end
end
