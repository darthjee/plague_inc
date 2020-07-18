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
      expect(population).to validate_presence_of(:interactions)
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

    it do
      expect(population).to validate_numericality_of(:interactions)
        .is_greater_than(0)
    end

    it do
      expect(population).to validate_numericality_of(:interactions)
        .only_integer
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

    let!(:immune_population) do
      create(:contagion_population, state: :immune, group: group)
    end

    let!(:dead_population) do
      create(:contagion_population, state: :dead, group: group)
    end

    describe '.infected' do
      it do
        expect(described_class.infected)
          .to match_array([infected_population])
      end
    end

    describe '.healthy' do
      it do
        expect(described_class.healthy)
          .to match_array([healthy_population])
      end
    end

    describe '.immune' do
      it do
        expect(described_class.immune)
          .to match_array([immune_population])
      end
    end

    describe '.not_healthy' do
      let(:expected) do
        [
            immune_population,
            infected_population,
            dead_population
        ]
      end

      it do
        expect(described_class.not_healthy)
          .to match_array(expected)
      end
    end
  end

  describe '#infected?' do
    subject(:population) { build(:contagion_population, state: state) }

    context 'when population is infected' do
      let(:state) { described_class::INFECTED }

      it do
        expect(population).to be_infected
      end
    end

    context 'when population is healthy' do
      let(:state) { described_class::HEALTHY }

      it do
        expect(population).not_to be_infected
      end
    end

    context 'when population is immune' do
      let(:state) { described_class::IMMUNE }

      it do
        expect(population).not_to be_infected
      end
    end
  end

  describe '#health?' do
    subject(:population) { build(:contagion_population, state: state) }

    context 'when population is infected' do
      let(:state) { described_class::INFECTED }

      it do
        expect(population).not_to be_healthy
      end
    end

    context 'when population is healthy' do
      let(:state) { described_class::HEALTHY }

      it do
        expect(population).to be_healthy
      end
    end

    context 'when population is immune' do
      let(:state) { described_class::IMMUNE }

      it do
        expect(population).not_to be_healthy
      end
    end
  end
end
