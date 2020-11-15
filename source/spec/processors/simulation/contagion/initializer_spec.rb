# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Initializer do
  let(:simulation) { create(:simulation, :processing) }
  let(:contagion)  { simulation.contagion }
  let(:instant) do
    create(:contagion_instant, contagion: contagion, day: 9)
  end

  let(:group)     { contagion.groups.last }
  let(:behavior)  { group.behavior }
  let(:days)      { Random.rand(1..10) }
  let(:dead_size) { Random.rand(1..100) }

  let(:new_instant) { described_class.process(instant) }

  let(:interesting_populations) do
    [dead_population, immune_population, infected_population]
  end

  let!(:infected_population) do
    create(
      :contagion_population,
      state: :infected,
      group: group,
      behavior: behavior,
      size: Random.rand(100),
      instant: instant,
      interactions: 10,
      days: days
    )
  end

  let!(:immune_population) do
    create(
      :contagion_population,
      state: :immune,
      group: group,
      behavior: behavior,
      size: Random.rand(100),
      instant: instant,
      interactions: 10,
      days: days
    )
  end

  let!(:dead_population) do
    create(
      :contagion_population,
      state: :dead,
      group: group,
      behavior: behavior,
      size: dead_size,
      instant: instant,
      interactions: 10,
      days: days
    )
  end

  before do
    create(
      :contagion_population,
      state: :healthy,
      group: group,
      behavior: behavior,
      size: Random.rand(100),
      instant: instant,
      interactions: 10,
      days: days
    )
  end

  describe '.process' do
    it 'updates simulation' do
      expect { new_instant }
        .to(change { simulation.reload.updated_at })
    end

    it 'does not update simulation status' do
      expect { new_instant }
        .not_to(change { simulation.reload.status })
    end

    it do
      expect { new_instant }
        .to change { instant.reload.status }
        .to(Simulation::Contagion::Instant::PROCESSING)
    end

    it do
      expect(new_instant)
        .to be_a(Simulation::Contagion::Instant)
    end

    it do
      expect(new_instant)
        .to be_persisted
    end

    it 'creates new instant' do
      expect(new_instant)
        .not_to eq(instant)
    end

    it 'creates new instant for a new day' do
      expect(new_instant.day)
        .to eq(10)
    end

    it 'creates populations for all infected populations' do
      expect(new_instant.populations)
        .not_to be_empty
    end

    it 'persists all populations' do
      expect(new_instant.populations)
        .to all(be_persisted)
    end

    it 'makes population for the important populations' do
      expect(new_instant.populations.sort.pluck(:state))
        .to eq(%w[dead immune infected])
    end

    it 'increments days counters' do
      expect(new_instant.populations.pluck(:days))
        .to eq([1, days + 1, days + 1])
    end

    it 'makes population with correct size' do
      expect(new_instant.populations.sort.pluck(:size))
        .to eq(interesting_populations.map(&:size))
    end

    context 'when there are more than one dead population' do
      let(:days)          { 0 }
      let(:old_size)      { Random.rand(1..100) }
      let(:expected_size) { dead_size + old_size }

      let(:state) do
        Simulation::Contagion::Population::DEAD
      end

      let!(:old_populations) do
        create(
          :contagion_population,
          interactions: 0,
          instant: instant,
          group: group,
          behavior: behavior,
          size: old_size,
          state: state,
          days: 1
        )
      end

      it do
        expect(new_instant.populations.dead.size)
          .to eq(1)
      end

      it do
        expect(new_instant.populations.dead.first.size)
          .to eq(expected_size)
      end

      it do
        expect(new_instant.populations.dead.first.days)
          .to eq(1)
      end
    end
  end
end
