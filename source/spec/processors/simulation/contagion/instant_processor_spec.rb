# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::InstantProcessor, :contagion_cache do
  let(:simulation) do
    build(:simulation, :processing, contagion: nil).tap do |sim|
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

  let(:lethality)             { 1 }
  let(:days_till_start_death) { 0 }
  let(:days_till_recovery)    { 1 }
  let(:infected)              { 1 }
  let(:interactions)          { 10 }
  let(:infected_days)         { 0 }
  let(:infected_interactions) do
    infected_size * interactions
  end

  let(:options) do
    Simulation::Processor::Options.new
  end

  before { contagion.reload }

  describe '.process' do
    context 'when there is a ready instant without healthy population' do
      let(:infected_size) { Random.rand(10..100) }

      let(:created_instant) do
        contagion.reload.instants.last
      end

      let(:created_populations) do
        created_instant.populations
      end

      let(:created_infected_populations) do
        created_populations.infected
      end

      let(:created_healthy_populations) do
        created_populations.healthy
      end

      let!(:ready_instant) do
        create(
          :contagion_instant,
          day: 0,
          status: :ready,
          contagion: contagion
        )
      end

      let(:process) do
        described_class.process(
          ready_instant, options, cache: cache
        )
      end

      before do
        create(
          :contagion_population, :infected,
          instant: ready_instant,
          group: group,
          behavior: behavior,
          size: infected_size,
          days: infected_days,
          interactions: infected_interactions
        )

        create(
          :contagion_population, :healthy,
          instant: ready_instant,
          group: group,
          behavior: behavior,
          size: 0,
          days: 0
        )
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it 'creates a new instant' do
        expect { process }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new ready instant' do
        process

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::CREATED)
      end

      it 'changes instant status' do
        expect { process }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSED)
      end

      it 'creates an infected population for the next day' do
        process
        expect(created_infected_populations.first.days)
          .to eq(infected_days + 1)
      end

      it 'does not create a healthy population for the next day' do
        process
        expect(created_healthy_populations)
          .to be_empty
      end
    end

    context 'when there is a ready instant' do
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

      let(:infected_populations) do
        ready_instant.reload.populations.infected
      end

      let(:healthy_populations) do
        ready_instant.reload.populations.healthy
      end

      let(:immune_populations) do
        ready_instant.reload.populations.immune
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

      let(:process) do
        described_class.process(
          ready_instant, options, cache: cache
        )
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it 'creates a new instant' do
        expect { process }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new ready instant' do
        process

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::CREATED)
      end

      it 'changes instant status' do
        expect { process }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSED)
      end

      context 'when death does not start' do
        before { process }

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

      it 'does not create a heaalthy population' do
        process
        expect(created_instant.populations.healthy).to be_empty
      end

      context 'when there is a healthy and an infected population' do
        let(:infected_size) { Random.rand(3..10) }
        let(:healthy_size)  { Random.rand(20..30) }
        let(:healthy_interactions) do
          healthy_size * interactions
        end

        let(:population_size_block) do
          proc do
            contagion
              .reload.instants
              .last.populations.sum(:size)
          end
        end

        before do
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

        it 'updates simulation' do
          expect { process }
            .to(change { simulation.reload.updated_at })
        end

        it 'does not update simulation status' do
          expect { process }
            .not_to(change { simulation.reload.status })
        end

        it 'consumes infected interaction' do
          expect { process }
            .to change { infected_populations.sum(:interactions) }
            .to(0)
        end

        it 'consumes healthy interaction' do
          expect { process }
            .to(change { healthy_populations.sum(:interactions) })
        end

        it 'creates a new instant' do
          expect { process }
            .to change { contagion.reload.instants.count }
            .by(1)
        end

        it 'keeps population size' do
          expect { process }
            .not_to change(&population_size_block)
        end

        it 'creates a heaalthy population' do
          process
          expect(created_instant.populations.healthy).not_to be_empty
        end
      end

      context 'when there is an immune and an infected population' do
        let(:infected_size) { Random.rand(3..10) }
        let(:immune_size) { Random.rand(20..30) }
        let(:immune_interactions) do
          immune_size * interactions
        end

        let(:population_size_block) do
          proc do
            contagion
              .reload.instants
              .last.populations.sum(:size)
          end
        end

        before do
          create(
            :contagion_population, :immune,
            instant: ready_instant,
            group: group,
            behavior: behavior,
            size: immune_size,
            interactions: immune_interactions,
            days: 0
          )
        end

        it 'updates simulation' do
          expect { process }
            .to(change { simulation.reload.updated_at })
        end

        it 'does not update simulation status' do
          expect { process }
            .not_to(change { simulation.reload.status })
        end

        it 'consumes infected interaction' do
          expect { process }
            .to change { infected_populations.sum(:interactions) }
            .to(0)
        end

        it 'consumes immune interaction' do
          expect { process }
            .to(change { immune_populations.sum(:interactions) })
        end

        it 'creates a new instant' do
          expect { process }
            .to change { contagion.reload.instants.count }
            .by(1)
        end

        it 'keeps population size' do
          expect { process }
            .not_to change(&population_size_block)
        end
      end
    end

    context 'when instant is already being processed' do
      let!(:processing_instant) do
        create(
          :contagion_instant,
          day: 0,
          status: :processing,
          contagion: contagion
        )
      end

      let!(:created_instant) do
        create(
          :contagion_instant,
          day: 1,
          status: :created,
          contagion: contagion
        )
      end

      let!(:infected_population) do
        create(
          :contagion_population, :infected,
          instant: processing_instant,
          group: group,
          behavior: behavior,
          size: infected_size,
          days: infected_days,
          interactions: infected_interactions
        )
      end

      let!(:healthy_population) do
        create(
          :contagion_population, :healthy,
          instant: processing_instant,
          group: group,
          behavior: behavior,
          size: healthy_size,
          days: 0,
          interactions: healthy_interactions
        )
      end

      let(:populations) do
        processing_instant.reload.populations
      end

      let(:infected_size) { Random.rand(3..10) }
      let(:healthy_size)  { 100 * infected_size }
      let(:healthy_interactions) do
        100 * infected_interactions
      end

      let(:process) do
        described_class.process(processing_instant, options, cache: cache)
      end

      before do
        populations.not_healthy do |pop|
          Simulation::Contagion::Population::Builder.build(
            instant: created_instant,
            population: pop
          )
        end
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it 'does not create a new instant' do
        expect { process }
          .not_to change(Simulation::Contagion::Instant, :count)
      end

      it 'consumes infected interactions' do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end

      it 'consumes healthy interactions' do
        expect { process }
          .to(change { healthy_population.reload.interactions })
      end

      it 'infects populations' do
        expect { process }
          .to change { created_instant.reload.populations.infected.count }
          .by(1)
      end
    end

    context 'when infected size is bigger than block size' do
      let(:days_till_start_death) { 2 }
      let(:days_till_recovery)    { 3 }
      let(:infected_size)         { 10 }
      let(:healthy_size)          { 100 }

      let(:healthy_interactions) do
        healthy_size * interactions
      end

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

      let(:infected_populations) do
        ready_instant.reload.populations.infected
      end

      let(:immune_populations) do
        ready_instant.reload.populations.immune
      end

      let!(:ready_instant) do
        create(
          :contagion_instant,
          day: 0,
          status: :ready,
          contagion: contagion
        )
      end

      let(:process) do
        described_class.process(
          ready_instant, options, cache: cache
        )
      end

      before do
        create(
          :contagion_population, :healthy,
          instant: ready_instant,
          group: group,
          behavior: behavior,
          size: healthy_size,
          days: 0,
          interactions: healthy_interactions
        )

        create(
          :contagion_population, :infected,
          instant: ready_instant,
          group: group,
          behavior: behavior,
          size: infected_size,
          days: infected_days,
          interactions: infected_interactions
        )

        allow(options)
          .to receive(:interaction_block_size)
          .and_return(1)
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it 'creates a new instant' do
        expect { process }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new created instant' do
        process

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::CREATED)
      end

      it 'changes instant status to processing' do
        expect { process }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSING)
      end

      it 'does not create a heaalthy population' do
        process
        expect(created_instant.populations.healthy).to be_empty
      end
    end
  end
end
