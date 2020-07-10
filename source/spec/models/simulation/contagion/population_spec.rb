# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Population, type: :model do
  subject(:population) { build(:contagion_population) }

  describe 'validations' do
    it { expect(population).to be_valid }

    it do
      expect(population).to validate_presence_of(:instant)
    end

    it do
      expect(population).to validate_presence_of(:group)
    end

    it do
      expect(population).to validate_presence_of(:behavior)
    end

    it do
      expect(population).to validate_presence_of(:size)
    end

    it do
      expect(population).not_to validate_presence_of(:infected_days)
    end

    it do
      expect(population).to validate_numericality_of(:size)
        .is_greater_than(0)
    end

    it do
      expect(population).to validate_numericality_of(:size)
        .only_integer
    end

    it do
      expect(population).to validate_numericality_of(:infected_days)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(population).to validate_numericality_of(:infected_days)
        .only_integer
    end
  end
end
