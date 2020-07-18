# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Initializer do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:instant) do
    create(:contagion_instant, contagion: contagion, day: 9)
  end

  let(:group)    { contagion.groups.last }
  let(:behavior) { group.behavior }

  let(:days) { Random.rand(1..10) }
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
    it do
      expect { described_class.process(instant) }
        .to change { instant.reload.status }
        .to(Simulation::Contagion::Instant::PROCESSING)
    end

    it do
      expect(described_class.process(instant))
        .to be_a(Simulation::Contagion::Instant)
    end

    it do
      expect(described_class.process(instant))
        .to be_persisted
    end

    it 'creates new instant' do
      expect(described_class.process(instant))
        .not_to eq(instant)
    end

    it 'creates new instant for a new day' do
      expect(described_class.process(instant).day)
        .to eq(10)
    end

    it 'creates populations for all infected populations' do
      expect(described_class.process(instant).populations)
        .not_to be_empty
    end

    it 'persists all populations' do
      expect(described_class.process(instant).populations)
        .to all(be_persisted)
    end

    it 'makes population for the important populations' do
      expect(described_class.process(instant).populations.pluck(:state))
        .to eq(%w[immune infected])
    end

    it 'increments days counters' do
      expect(described_class.process(instant).populations.pluck(:days))
        .to all(eq(days + 1))
    end

    it 'makes population with correct size' do
      expect(described_class.process(instant).populations.pluck(:size))
        .to eq([immune_population.size, infected_population.size])
    end
  end
end
