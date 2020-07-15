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
      expect(population).to validate_presence_of(:days)
    end

    it do
      expect(population).to validate_presence_of(:state)
    end

    it do
      expect(population).to validate_numericality_of(:size)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(population).to validate_numericality_of(:size)
        .only_integer
    end

    it do
      expect(population).to validate_numericality_of(:days)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(population).to validate_numericality_of(:days)
        .only_integer
    end

    it do
      expect(population).to validate_inclusion_of(:state)
        .in_array(described_class::STATES)
    end
  end

  describe 'scopes' do
    let(:simulation) { create(:simulation) }
    let(:group)      { simulation.contagion.groups.first }

    let!(:infected_population) do
      create(:contagion_population, state: :infected, group: group)
    end

    let!(:healthy_population) do
      create(:contagion_population, state: :healthy, group: group)
    end

    describe '.infected' do
      it do
        expect(described_class.infected)
          .to include(infected_population)
      end

      it do
        expect(described_class.infected)
          .not_to include(healthy_population)
      end
    end

    describe '.healthy' do
      it do
        expect(described_class.healthy)
          .not_to include(infected_population)
      end

      it do
        expect(described_class.healthy)
          .to include(healthy_population)
      end
    end
  end
end
