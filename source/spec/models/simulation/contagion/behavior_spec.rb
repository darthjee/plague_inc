# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Contagion::Behavior, type: :model do
  subject(:behavior) { build(:contagion_behavior) }

  describe 'validations' do
    it do
      expect(behavior).to validate_presence_of(:name)
    end

    it do
      expect(behavior).to validate_presence_of(:reference)
    end

    it do
      expect(behavior).to validate_length_of(:name)
        .is_at_most(255)
    end

    it do
      expect(behavior).to validate_presence_of(:contagion)
    end

    it do
      expect(behavior).to validate_numericality_of(:interactions)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(behavior).to validate_numericality_of(:interactions)
        .only_integer
    end

    it do
      expect(behavior).to validate_inclusion_of(:contagion_risk)
        .in_range((0.0..1.0))
    end

    it do
      expect(behavior).to validate_length_of(:reference)
        .is_at_most(10)
    end
  end
end
