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
      expect(population).not_to validate_presence_of(:new_infections)
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
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(population).to validate_numericality_of(:interactions)
        .only_integer
    end

    it do
      expect(population).to validate_numericality_of(:new_infections)
        .is_greater_than_or_equal_to(0)
    end

    it do
      expect(population).to validate_numericality_of(:new_infections)
        .only_integer
    end
  end

  describe 'scopes' do
    let(:simulation) { create(:simulation) }
    let(:group)      { simulation.contagion.groups.first }
    let(:days)       { Random.rand(10) }

    let!(:infected_population) do
      create(
        :contagion_population,
        state: :infected,
        group: group,
        days: days
      )
    end

    let!(:healthy_population) do
      create(
        :contagion_population,
        state: :healthy,
        group: group,
        days: days
      )
    end

    let!(:immune_population) do
      create(
        :contagion_population,
        state: :immune,
        group: group,
        days: days
      )
    end

    let!(:dead_population) do
      create(
        :contagion_population,
        state: :dead,
        group: group,
        days: days
      )
    end

    describe '.infected' do
      it do
        expect(described_class.infected)
          .to contain_exactly(infected_population)
      end
    end

    describe '.healthy' do
      it do
        expect(described_class.healthy)
          .to contain_exactly(healthy_population)
      end
    end

    describe '.immune' do
      it do
        expect(described_class.immune)
          .to contain_exactly(immune_population)
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

    describe '.alive' do
      let(:expected) do
        [
          immune_population,
          infected_population,
          healthy_population
        ]
      end

      it do
        expect(described_class.alive)
          .to match_array(expected)
      end
    end

    describe '.recent' do
      context 'when days is not 0' do
        let(:days) { Random.rand(1..10) }

        it do
          expect(described_class.recent)
            .to be_empty
        end
      end

      context 'when days is 0' do
        let(:days) { 0 }

        let(:expected) do
          [
            immune_population,
            infected_population,
            healthy_population,
            dead_population
          ]
        end

        it do
          expect(described_class.recent)
            .to match_array(expected)
        end
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

    context 'when population is dead' do
      let(:state) { described_class::DEAD }

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

    context 'when population is dead' do
      let(:state) { described_class::DEAD }

      it do
        expect(population).not_to be_healthy
      end
    end
  end

  describe '#dead?' do
    subject(:population) { build(:contagion_population, state: state) }

    context 'when population is infected' do
      let(:state) { described_class::INFECTED }

      it do
        expect(population).not_to be_dead
      end
    end

    context 'when population is healthy' do
      let(:state) { described_class::HEALTHY }

      it do
        expect(population).not_to be_dead
      end
    end

    context 'when population is immune' do
      let(:state) { described_class::IMMUNE }

      it do
        expect(population).not_to be_dead
      end
    end

    context 'when population is dead' do
      let(:state) { described_class::DEAD }

      it do
        expect(population).to be_dead
      end
    end
  end

  describe '#remaining_size' do
    subject(:population) do
      build(:contagion_population, size: 100, new_infections: 20)
    end

    it 'returns remaining population size' do
      expect(population.remaining_size).to eq(80)
    end
  end

  describe '#interactions?' do
    subject(:population) do
      build(:contagion_population, interactions: interactions)
    end

    context 'when there are interactions' do
      let(:interactions) { Random.rand(1..10) }

      it do
        expect(population).to be_interactions
      end
    end

    context 'when there are no interactions' do
      let(:interactions) { 0 }

      it do
        expect(population).not_to be_interactions
      end
    end
  end

  describe '#setup_interactions' do
    subject(:population) do
      build(
        :contagion_population,
        size: size,
        behavior: behavior,
        interactions: 0
      )
    end

    let(:behavior) do
      build(:contagion_behavior, interactions: interactions)
    end

    let(:size)         { Random.rand(10..100) }
    let(:interactions) { Random.rand(10..100) }
    let(:expected_interactions) do
      interactions * size
    end

    it do
      expect { population.setup_interactions }
        .to change(population, :interactions)
        .from(0).to(expected_interactions)
    end
  end
end
