# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Initializer, :contagion_cache do
  let(:simulation) do
    build(:simulation, contagion: nil).tap do |sim|
      sim.save(validate: false)
    end
  end

  let(:contagion) do
    build(
      :contagion,
      simulation: simulation,
      days_till_immunization_end: days_till_immunization_end
    ).tap do |con|
      con.save(validate: false)
    end
  end

  let(:instant) do
    create(:contagion_instant, contagion: contagion, day: 9)
  end

  let(:group)         { contagion.groups.last }
  let(:behavior)      { group.behavior }
  let(:days)          { Random.rand(1..10) }
  let(:dead_size)     { Random.rand(1..100) }
  let(:immune_size)   { Random.rand(1..100) }
  let(:infected_size) { Random.rand(1..100) }

  let(:days_till_immunization_end) do
    Random.rand(3)
  end

  let(:new_instant) { described_class.process(instant, cache: cache) }

  let(:interesting_populations) do
    [dead_population, immune_population, infected_population]
  end

  let!(:infected_population) do
    create(
      :contagion_population,
      state: :infected,
      group: group,
      behavior: behavior,
      size: infected_size,
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
      size: immune_size,
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
      let(:old_group)     { group }

      let(:state) do
        Simulation::Contagion::Population::DEAD
      end

      before do
        create(
          :contagion_population,
          interactions: 0,
          instant: instant,
          group: old_group,
          behavior: behavior,
          size: old_size,
          state: state,
          days: 1
        )
      end

      it 'merge populations' do
        expect(new_instant.populations.dead.size)
          .to eq(1)
      end

      it 'merge populations sizes' do
        expect(new_instant.populations.dead.first.size)
          .to eq(expected_size)
      end

      it 'mark new population as day 1' do
        expect(new_instant.populations.dead.first.days)
          .to eq(1)
      end

      context 'when there are different group dead populations' do
        let(:expected_sizes) { [dead_size, old_size] }
        let(:old_group) do
          create(
            :contagion_group,
            contagion: contagion,
            behavior: behavior
          )
        end

        it 'does not merge populations' do
          expect(new_instant.populations.dead.size)
            .to eq(2)
        end

        it 'does not merge populations sizes' do
          expect(new_instant.populations.dead.pluck(:size))
            .to eq(expected_sizes)
        end

        it 'mark new populations as day 1' do
          expect(new_instant.populations.dead.pluck(:days))
            .to all(eq(1))
        end
      end
    end

    context 'when there are more than one immune population' do
      let(:days)           { 0 }
      let(:old_size)       { Random.rand(1..100) }
      let(:expected_sizes) { [immune_size, old_size] }
      let(:old_group)      { group }

      let(:state) do
        Simulation::Contagion::Population::IMMUNE
      end

      before do
        create(
          :contagion_population,
          interactions: 0,
          instant: instant,
          group: old_group,
          behavior: behavior,
          size: old_size,
          state: state,
          days: 1
        )
      end

      it 'does not merge populations' do
        expect(new_instant.populations.immune.size)
          .to eq(2)
      end

      it 'does not merge populations sizes' do
        expect(new_instant.populations.immune.pluck(:size))
          .to eq(expected_sizes)
      end

      it 'mark new populations as day 1' do
        expect(new_instant.populations.immune.pluck(:days))
          .to eq([1, 2])
      end
    end

    context 'when there are more than one infected population' do
      let(:days)           { 0 }
      let(:old_size)       { Random.rand(1..100) }
      let(:expected_sizes) { [infected_size, old_size] }
      let(:old_group)      { group }

      let(:state) do
        Simulation::Contagion::Population::INFECTED
      end

      before do
        create(
          :contagion_population,
          interactions: 0,
          instant: instant,
          group: old_group,
          behavior: behavior,
          size: old_size,
          state: state,
          days: 1
        )
      end

      it 'does not merge populations' do
        expect(new_instant.populations.infected.size)
          .to eq(2)
      end

      it 'does not merge populations sizes' do
        expect(new_instant.populations.infected.pluck(:size))
          .to eq(expected_sizes)
      end

      it 'mark new populations as day 1' do
        expect(new_instant.populations.infected.pluck(:days))
          .to eq([1, 2])
      end
    end
  end

  context 'when population never looses immunization' do
    let(:days_till_immunization_end) { nil }

    it 'makes population for the important populations' do
      expect(new_instant.populations.sort.pluck(:state))
        .to eq(%w[dead immune infected])
    end

    it 'increments days counters for non aggregated' do
      expect(new_instant.populations.pluck(:days))
        .to eq([1, 1, days + 1])
    end

    it 'makes population with correct size' do
      expect(new_instant.populations.sort.pluck(:size))
        .to eq(interesting_populations.map(&:size))
    end
  end
end
