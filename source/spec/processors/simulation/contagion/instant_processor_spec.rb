# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::InstantProcessor do
  let(:simulation) do
    build(:simulation, contagion: nil).tap do |sim|
      sim.save(validate: false)
    end
  end

  let(:contagion) do
    build(
      :contagion,
      simulation: simulation,
      days_till_start_death: days_till_start_death,
      days_till_recovery: days_till_recovery,
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

  let!(:behavior) do
    create(
      :contagion_behavior,
      contagion: contagion,
      interactions: interactions
    )
  end

  let(:instant) { contagion.reload.instants.last }

  let(:days_till_start_death) { 0 }
  let(:days_till_recovery)    { 1 }
  let(:infected)              { 1 }
  let(:interactions)          { 10 }
  let(:infected_interactions) do
    infected_size * interactions
  end

  before { contagion.reload }

  describe '.process' do
    context 'when there is a ready instant' do
      let(:lethality)             { 1 }
      let(:infected_days)         { 0 }
      let(:days_till_start_death) { 2 }
      let(:days_till_recovery)    { 3 }
      let(:infected_size)         { 1 }

      let(:created_instant) do
        contagion.reload.instants.last
      end

      let(:created_populations) do
        created_instant.populations
      end

      let(:created_infected_populations) do
        created_populations.infected
      end

      let(:created_immune_populations) do
        created_populations.immune
      end

      let(:created_dead_populations) do
        created_populations.dead
      end

      let!(:ready_instant) do
        create(
          :contagion_instant,
          day: 0,
          status: :ready,
          contagion: contagion
        )
      end

      let!(:infected_population) do
        create(
          :contagion_population, :infected,
          instant: ready_instant,
          group: group,
          behavior: behavior,
          size: infected_size,
          days: infected_days,
          interactions: infected_interactions
        )
      end

      it 'creates a new instant' do
        expect { described_class.process(ready_instant) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new ready instant' do
        described_class.process(ready_instant)

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::CREATED)
      end

      it 'changes instant status' do
        expect { described_class.process(ready_instant) }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSED)
      end

      context 'when death does not start' do
        before { described_class.process(ready_instant) }

        it 'creates a new population from infected' do
          expect(created_infected_populations)
            .not_to be_empty
        end

        it 'does not create a new dead population' do
          expect(created_dead_populations)
            .to be_empty
        end

        it 'does not create a new immune population' do
          expect(created_immune_populations)
            .to be_empty
        end

        it 'creates a new population for infected group' do
          expect(created_infected_populations.first.group)
            .to eq(group)
        end

        it 'creates a new population for infected behavior' do
          expect(created_infected_populations.first.behavior)
            .to eq(behavior)
        end

        it 'increases day counter' do
          expect(created_infected_populations.first.days)
            .to eq(infected_population.days + 1)
        end

        it 'keeps size' do
          expect(created_infected_populations.first.size)
            .to eq(infected_population.size)
        end

        it 'consumes infected interaction' do
          infected = ready_instant.reload.populations.infected
          expect(infected.sum(:interactions)).to be_zero
        end
      end

      context 'when there is a healthy and an infected population' do
        let(:infected_size) { Random.rand(3..10) }
        let(:healthy_size)  { Random.rand(20..30) }
        let(:healthy_interactions) do
          healthy_size * interactions
        end

        let!(:healthy_population) do
          create(
            :contagion_population, :healthy,
            instant: ready_instant,
            group: group,
            behavior: behavior,
            size: healthy_size,
            interactions: healthy_interactions,
            days: 0
          )
        end

        let(:infected_populations) do
          ready_instant.reload.populations.infected
        end

        let(:healthy_populations) do
          ready_instant.reload.populations.healthy
        end

        let(:population_size_block) do
          proc do
            contagion
              .reload.instants
              .last.populations.sum(:size)
          end
        end

        it 'consumes infected interaction' do
          expect { described_class.process(ready_instant) }
            .to change { infected_populations.sum(:interactions) }
            .to(0)
        end

        it 'consumes healthy interaction' do
          expect { described_class.process(ready_instant) }
            .to change { healthy_populations.sum(:interactions) }
        end

        it 'creates a new instant' do
          expect { described_class.process(ready_instant) }
            .to change { contagion.reload.instants.count }
            .by(1)
        end

        it 'keeps population size' do
          expect { described_class.process(ready_instant) }
            .not_to change(&population_size_block)
        end
      end
    end
  end
end
