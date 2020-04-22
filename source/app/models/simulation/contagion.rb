# frozen_string_literal: true

class Simulation < ApplicationRecord
  class Contagion < ApplicationRecord
    belongs_to :simulation

    validates_presence_of :simulation,
      :lethality,
      :days_till_recovery,
      :days_till_sympthoms,
      :days_till_start_death

    validates_inclusion_of :lethality, in: ((0.0..1.0))
  end
end
