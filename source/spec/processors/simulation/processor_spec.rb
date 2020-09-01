# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Processor do
  let(:simulation) do
    build(:simulation, contagion: nil, status: current_status).tap do |sim|
      sim.save(validate: false)
    end
  end

  let(:contagion) do
    build(
      :contagion,
      simulation: simulation,
      days_till_start_death: days_till_start_death,
      days_till_recovery: days_till_recovery,
      days_till_sympthoms: days_till_sympthoms,
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
      contagion: contagion,
      size: size
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

  let(:size)                  { 100 }
  let(:current_status)        { Simulation::CREATED }
  let(:days_till_start_death) { 0 }
  let(:days_till_recovery)    { 1 }
  let(:days_till_sympthoms)   { 0 }
  let(:infected)              { 1 }
  let(:interactions)          { 10 }
  let(:lethality)             { 1 }
  let(:infected_interactions) do
    infected_size * interactions
  end

  before { contagion.reload }

  describe '.process' do
    context 'when there are no instants' do
      it do
        expect { described_class.process(simulation) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it do
        expect { described_class.process(simulation) }
          .to change { simulation.reload.status }
          .from(Simulation::CREATED)
          .to(Simulation::FINISHED)
      end

      it do
        expect(described_class.process(simulation))
          .to be_a(Array)
      end

      it do
        expect(described_class.process(simulation))
          .to all(be_a(Simulation::Contagion::Instant))
      end

      context 'when calling for more times' do
        let(:days_till_start_death) { 10 }
        let(:days_till_recovery)    { 10 }
        let(:infected)              { 1 }

        let(:times) { Random.rand(3..6) }

        let(:expected_statuses) do
          (times - 1).times.map do
            Simulation::Contagion::Instant::PROCESSED
          end.push(Simulation::Contagion::Instant::READY)
        end

        it do
          expect { described_class.process(simulation, times: times) }
            .to change { contagion.reload.instants.count }
            .by(times)
        end

        it 'makes instants with correct states' do
          described_class.process(simulation, times: times)

          expect(contagion.reload.instants.pluck(:status))
            .to eq(expected_statuses)
        end
      end

      context 'when it is finished' do
        let(:current_status) { Simulation::FINISHED }

        it do
          expect { described_class.process(simulation) }
            .not_to(change { contagion.reload.instants.count })
        end
      end

      context 'when it becomes finished' do
        let(:infected) { size }

        it do
          expect { described_class.process(simulation, times: 10) }
            .to change { contagion.reload.instants.count }
            .by(1)
        end
      end

      context 'when processing is complete' do
        before { described_class.process(simulation) }

        it 'generates instant for day 0' do
          expect(instant.day).to be_zero
        end

        it 'sets correct status of instant' do
          expect(instant.reload.status)
            .to eq(Simulation::Contagion::Instant::READY)
        end

        it 'generates populations' do
          expect(instant.populations.size).to eq(3)
        end

        it 'builds and kills' do
          expect(instant.populations.map(&:state))
            .to eq(%w[healthy infected dead])
        end

        it 'persists all populations' do
          expect(instant.populations)
            .to all(be_persisted)
        end
      end
    end

    context 'when there is a created instant' do
      let(:lethality)          { 0 }
      let(:days_till_recovery) { 0 }

      let!(:created_instant) do
        Simulation::Contagion::Starter.process(contagion)
      end

      it do
        expect { described_class.process(simulation) }
          .not_to(change { contagion.reload.instants.count })
      end

      it do
        expect { described_class.process(simulation) }
          .to change { created_instant.reload.status }
          .from(Simulation::Contagion::Instant::CREATED)
          .to(Simulation::Contagion::Instant::READY)
      end

      it do
        expect { described_class.process(simulation) }
          .not_to(change { created_instant.reload.populations.count })
      end

      it do
        expect { described_class.process(simulation) }
          .to change { created_instant.reload.populations.map(&:state) }
          .from(%w[healthy infected])
          .to(%w[healthy immune])
      end

      context 'when processing is complete' do
        before { described_class.process(simulation) }

        it 'persists all populations' do
          expect(instant.populations)
            .to all(be_persisted)
        end
      end
    end

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
        expect { described_class.process(simulation) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new ready instant' do
        described_class.process(simulation)

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::READY)
      end

      it 'changes instant status' do
        expect { described_class.process(simulation) }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSED)
      end

      context 'when death does not start' do
        before { described_class.process(simulation) }

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

      context 'when death kills everyone' do
        let(:days_till_start_death) { 1 }

        before { described_class.process(simulation) }

        it 'creates a new infected population' do
          expect(created_infected_populations)
            .not_to be_empty
        end

        it 'creates a new dead population' do
          expect(created_dead_populations)
            .not_to be_empty
        end

        it 'does not create a new immune population' do
          expect(created_immune_populations)
            .to be_empty
        end

        it 'increases day counter' do
          expect(created_infected_populations.first.days)
            .to eq(infected_population.days + 1)
        end

        it 'reduces infected size' do
          expect(created_infected_populations.first.size)
            .to be_zero
        end

        it 'creates a new population for infected group' do
          expect(created_dead_populations.first.group)
            .to eq(group)
        end

        it 'creates a new population for infected behavior' do
          expect(created_dead_populations.first.behavior)
            .to eq(behavior)
        end

        it 'resets day counter' do
          expect(created_dead_populations.first.days)
            .to be_zero
        end

        it 'keeps size' do
          expect(created_dead_populations.first.size)
            .to eq(infected_population.size)
        end

        it 'consumes infected interaction' do
          infected = ready_instant.reload.populations.infected
          expect(infected.sum(:interactions)).to be_zero
        end
      end

      context 'when death kills no one and and recovery happens' do
        let(:days_till_start_death) { 1 }
        let(:days_till_recovery)    { 1 }
        let(:lethality)             { 0 }

        before { described_class.process(simulation) }

        it 'does not create a new infected population' do
          expect(created_infected_populations)
            .to be_empty
        end

        it 'does not create a new dead population' do
          expect(created_dead_populations)
            .to be_empty
        end

        it 'creates a new immune population' do
          expect(created_immune_populations)
            .not_to be_empty
        end

        it 'resets day counter' do
          expect(created_immune_populations.first.days)
            .to be_zero
        end

        it 'keeps size' do
          expect(created_immune_populations.first.size)
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

        it 'consumes infected interaction' do
          expect { described_class.process(simulation) }
            .to change { infected_populations.sum(:interactions) }
            .to(0)
        end

        it 'consumes healthy interaction' do
          expect { described_class.process(simulation) }
            .to(change { healthy_populations.sum(:interactions) })
        end

        it 'creates a new instant' do
          expect { described_class.process(simulation) }
            .to change { contagion.reload.instants.count }
            .by(1)
        end

        it 'keeps population size' do
          expect { described_class.process(simulation) }
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

      let(:infected_days) { 0 }
      let(:infected_size) { Random.rand(3..10) }
      let(:healthy_size)  { 100 * infected_size }
      let(:healthy_interactions) do
        100 * infected_interactions
      end

      before do
        populations.not_healthy do |pop|
          Simulation::Contagion::Population::Builder.build(
            instant: created_instant,
            population: pop
          )
        end
      end

      it 'does not create a new instant' do
        expect { described_class.process(simulation) }
          .not_to change(Simulation::Contagion::Instant, :count)
      end

      it 'consumes infected interactions' do
        expect { described_class.process(simulation) }
          .to change { infected_population.reload.interactions }
          .to(0)
      end

      it 'consumes healthy interactions' do
        expect { described_class.process(simulation) }
          .to(change { healthy_population.reload.interactions })
      end

      it 'infects populations' do
        expect { described_class.process(simulation) }
          .to change { created_instant.reload.populations.infected.count }
          .by(1)
      end
    end
  end
end
