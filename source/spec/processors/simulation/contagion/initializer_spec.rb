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

  let!(:infected_population) do
    create(
      :contagion_population,
      state: :infected,
      group: group,
      behavior: behavior,
      size: Random.rand(100),
      instant: instant,
      interactions: 10
    )
  end

  let!(:healthy_population) do
    create(
      :contagion_population,
      state: :healthy,
      group: group,
      behavior: behavior,
      size: Random.rand(100),
      instant: instant,
      interactions: 10
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
      interactions: 10
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

    it "creates new instant" do
      expect(described_class.process(instant))
        .not_to eq(instant)
    end

    it "creates new instant for a new day" do
      expect(described_class.process(instant).day)
        .to eq(10)
    end

    it "creates populations for all infected populations" do
      expect(described_class.process(instant).populations)
        .not_to be_empty
    end

    it 'persists all populations' do
      expect(described_class.process(instant).populations)
        .to all(be_persisted)
    end
  end
end
