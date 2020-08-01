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
        interactions: interactions
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

    let(:random_box)    { RandomBox.instance }
    let(:day)           { 0 }
    let(:infected)      { 1 }
    let(:lethality)     { 1 }
    let(:infected_size) { Random.rand(3..10) }
    let(:interactions)  { Random.rand(1..10) }

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
  end
end
