# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    belongs_to :simulation

    validates_presence_of :simulation

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

    validate :validate_days

    private

    def validate_days
      return unless days_till_recovery

      if days_till_recovery < days_till_sympthoms.to_i
        errors.add(
          :days_till_sympthoms,
          "cannot be greater than days to recovery"
        )
      end

      if days_till_recovery < days_till_start_death.to_i
        errors.add(
          :days_till_start_death,
          "cannot be greater than days to recovery"
        )
      end
    end
  end
end
