# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Population::Builder do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:behavior)   { contagion.behaviors.last }
  let(:group) do
    create(
      :contagion_group,
      contagion: contagion,
      behavior: behavior,
      size: size,
      infected: infected
    )
  end

  let(:size)     { 300 }
  let(:infected) { 100 }

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  describe '.build' do
    context 'when building from group' do
      subject(:population) do
        described_class.build(
          instant: instant,
          group: group,
          state: state
        )
      end

      context 'when state is healthy' do
        let(:state) do
          Simulation::Contagion::Population::HEALTHY
        end

        it do
          expect(population).not_to be_persisted
        end

        it do
          expect(population)
            .to be_a(Simulation::Contagion::Population)
        end

        it do
          expect(population.instant)
            .to eq(instant)
        end

        it do
          expect(population.behavior)
            .to eq(behavior)
        end

        it 'creates population with right healthy size' do
          expect(population.size)
            .to eq(size - infected)
        end

        it do
          expect(population).to be_healthy
        end

        it 'sets day to be 0' do
          expect(population.days).to be_zero
        end
      end

      context 'when state is infected' do
        let(:state) do
          Simulation::Contagion::Population::INFECTED
        end

        it do
          expect(population).not_to be_persisted
        end

        it do
          expect(population)
            .to be_a(Simulation::Contagion::Population)
        end

        it do
          expect(population.instant)
            .to eq(instant)
        end

        it do
          expect(population.behavior)
            .to eq(behavior)
        end

        it 'creates population with right infected size' do
          expect(population.size)
            .to eq(infected)
        end

        it do
          expect(population).to be_infected
        end

        it 'sets day to be 0' do
          expect(population.days).to be_zero
        end
      end
    end

    context 'when building from another population' do
      subject(:population) do
        described_class.build(
          instant: instant,
          population: previous_population
        )
      end

      let(:state) do
        Simulation::Contagion::Population::INFECTED
      end

      let(:previous_population) do
        create(:contagion_population, group: group, state: state)
      end

      let(:previous_instant) { previour_population.instant }

      context 'when using a healthy population' do
        it do
          expect(population).not_to be_persisted
        end

        it do
          expect(population)
            .to be_a(Simulation::Contagion::Population)
        end

        it do
          expect(population.instant)
            .to eq(instant)
        end

        it do
          expect(population.behavior)
            .to eq(behavior)
        end

        it 'creates population with right size' do
          expect(population.size)
            .to eq(group.infected)
        end

        it do
          expect(population).to be_infected
        end

        it 'increment days' do
          expect(population.days).to eq(1)
        end
      end
    end
  end
end
