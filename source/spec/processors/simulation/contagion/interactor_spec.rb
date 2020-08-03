# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Interactor do
  describe '.process' do
    let(:simulation) do
      build(:simulation, contagion: nil).tap do |sim|
        sim.save(validate: false)
      end
    end

    let(:contagion) do
      build(
        :contagion,
        simulation: simulation,
        lethality: lethality,
        groups: [],
        behaviors: []
      ).tap do |con|
        con.save(validate: false)
      end
    end

    let!(:group) do
      create(
        :contagion_group,
        infected: infected,
        behavior: behavior,
        contagion: contagion
      )
    end

    let(:second_group) do
      create(
        :contagion_group,
        infected: infected,
        behavior: behavior,
        contagion: contagion
      )
    end

    let!(:behavior) do
      create(
        :contagion_behavior,
        contagion: contagion,
        interactions: interactions,
        contagion_risk: contagion_risk
      )
    end

    let!(:current_instant) do
      create(
        :contagion_instant,
        contagion: contagion,
        day: day
      )
    end

    let!(:new_instant) do
      Simulation::Contagion::Initializer.process(
        current_instant
      )
    end

    let!(:infected_population) do
      create(
        :contagion_population, :infected,
        interactions: infected_interactions,
        instant: current_instant,
        group: group,
        size: infected_size,
        behavior: behavior
      )
    end

    let(:random_box)     { RandomBox.instance }
    let(:day)            { 0 }
    let(:infected)       { 1 }
    let(:lethality)      { 1 }
    let(:infected_size)  { Random.rand(3..10) }
    let(:interactions)   { Random.rand(1..10) }
    let(:contagion_risk) { Random.rand(0.2..0.8) }

    let(:infected_interactions) { infected_size * interactions }
    let(:healthy_size)          { 100 * infected_size }
    let(:healthy_interactions)  { healthy_size * interactions }

    let(:infected_population_query) do
      current_instant.populations.infected
    end

    it do
      expect { described_class.process(current_instant, new_instant) }
        .to change { current_instant.reload.status }
        .from(Simulation::Contagion::Instant::PROCESSING)
        .to(Simulation::Contagion::Instant::PROCESSED)
    end

    it do
      expect { described_class.process(current_instant, new_instant) }
        .to change { new_instant.reload.status }
        .from(Simulation::Contagion::Instant::CREATED)
        .to(Simulation::Contagion::Instant::READY)
    end

    context 'when there is only an infected population' do
      it do
        expect { described_class.process(current_instant, new_instant) }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create a new population' do
        expect { described_class.process(current_instant, new_instant) }
          .not_to change{ new_instant.populations.reload.count }
      end

      it 'does not increase infected populations size' do
        expect { described_class.process(current_instant, new_instant) }
          .not_to change{ new_instant.populations.reload.sum(:size) }
      end
    end

    context 'when there is a healthy population' do
      let!(:healthy_population) do
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior
        )
      end

      it do
        expect { described_class.process(current_instant, new_instant) }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'creates a new population' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.count }
          .by(1)
      end

      it 'increase infected populations size' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.sum(:size) }
      end

      it 'consumes interactions from healthy population' do
        expect { described_class.process(current_instant, new_instant) }
          .to change { healthy_population.reload.interactions }
      end
    end

    context 'when there is a another infected population' do
      let!(:second_population) do
        create(
          :contagion_population, :infected,
          interactions: infected_interactions,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
      end

      it do
        expect { described_class.process(current_instant, new_instant) }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create a new population' do
        expect { described_class.process(current_instant, new_instant) }
          .not_to change{ new_instant.populations.reload.count }
      end

      it 'does not increase infected populations size' do
        expect { described_class.process(current_instant, new_instant) }
          .not_to change{ new_instant.populations.reload.sum(:size) }
      end
    end

    context 'when there are other populations' do
      let(:healthy_size)   { infected_size }
      let(:contagion_risk) { 1 }

      before do
        create(
          :contagion_population, :infected,
          interactions: infected_interactions,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior,
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: second_group,
          size: healthy_size,
          behavior: behavior
        )

        allow(random_box).to receive(:interaction) do |max|
          max - 1
        end
      end

      it do
        expect { described_class.process(current_instant, new_instant) }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'creates a new population for the healthy population' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.count }
          .by(2)
      end

      it 'increases infected populations size' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.sum(:size) }
          .by(2 * healthy_size)
      end
    end

    context 'when one population has been processed already' do
      let(:healthy_size)   { infected_size }
      let(:infected_size)  { 2 * Random.rand(3..10) }
      let(:contagion_risk) { 1 }

      before do
        create(
          :contagion_population, :infected,
          interactions: 0,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions / 2,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior,
          new_infections: healthy_size / 2
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions / 2,
          instant: current_instant,
          group: second_group,
          size: healthy_size,
          behavior: behavior,
          new_infections: healthy_size / 2
        )

        create(
          :contagion_population, :infected,
          interactions: healthy_interactions / 2,
          instant: new_instant,
          group: group,
          size: healthy_size / 2,
          behavior: behavior
        )
        create(
          :contagion_population, :infected,
          interactions: healthy_interactions / 2,
          instant: new_instant,
          group: second_group,
          size: healthy_size / 2,
          behavior: behavior
        )

        allow(random_box).to receive(:interaction) do |max|
          max - 1
        end
      end

      it 'consumes interactions' do
        expect { described_class.process(current_instant, new_instant) }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create new populations' do
        expect { described_class.process(current_instant, new_instant) }
          .not_to change{ new_instant.populations.reload.count }
      end

      it 'increases infected populations size' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.sum(:size) }
          .by(healthy_size)
      end

      it 'increases infected populations interactions' do
        expect { described_class.process(current_instant, new_instant) }
          .to change{ new_instant.populations.reload.sum(:interactions) }
          .by(healthy_interactions)
      end
    end
  end
end
