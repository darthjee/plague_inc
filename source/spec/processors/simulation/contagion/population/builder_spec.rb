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

        it 'does not add interactions' do
          expect(population.interactions)
            .to be_zero
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

        it 'does not add interactions' do
          expect(population.interactions)
            .to be_zero
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

      let(:previous_population) do
        create(:contagion_population, group: group, state: state)
      end

      let(:previous_instant) { previour_population.instant }

      let(:state) do
        Simulation::Contagion::Population::STATES.sample
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

      it 'creates population with right size' do
        expect(population.size)
          .to eq(previous_population.size)
      end

      it do
        expect(population.state).to eq(state)
      end

      it 'increment days' do
        expect(population.days).to eq(1)
      end

      it 'does not add interactions' do
        expect(population.interactions)
          .to be_zero
      end
    end

    context 'when building passing extra params' do
      subject(:population) do
        described_class.build(
          instant: instant,
          group: group,
          behavior: new_behavior,
          state: state,
          interactions: 0,
          size: size
        )
      end

      let(:size) { Random.rand(100..119) }
      let(:state) do
        Simulation::Contagion::Population::DEAD
      end

      let(:new_behavior) do
        create(:contagion_behavior, contagion: contagion)
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
          .to eq(new_behavior)
      end

      it 'creates population with given size' do
        expect(population.size).to eq(size)
      end

      it 'creates population with given state' do
        expect(population.state).to eq(state)
      end

      it 'initialize days' do
        expect(population.days).to be_zero
      end

      it 'sets interactions' do
        expect(population.interactions)
          .to be_zero
      end

      context 'when there is already a population for same params' do
        let!(:previous_population) do
          described_class.build(
            instant: instant,
            group: group,
            behavior: new_behavior,
            state: state,
            interactions: initial_interactions,
            size: initial_size
          ).tap(&:save!)
        end

        let(:initial_interactions) { 10 * initial_size }
        let(:initial_size)         { Random.rand(50..249) }

        it 'changes size of preexisting population' do
          expect(population.id)
            .to eq(previous_population.id)
        end

        it 'sums sizes' do
          expect(population.size)
            .to eq(size + initial_size)
        end

        it 'changes instantce population size' do
          expect { population }
            .to change { instant.populations.first.size }
            .by(size)
        end
      end
    end
  end
end
