# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Processor do
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
    create(:contagion_behavior, contagion: contagion)
  end

  let(:instant) { contagion.reload.instants.last }

  let(:days_till_start_death) { 0 }
  let(:days_till_recovery)    { 1 }
  let(:infected)              { 1 }

  before { contagion.reload }

  describe '.process' do
    context 'when there are no instants' do
      let(:lethality) { 1 }

      it do
        expect { described_class.process(contagion) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      context 'when processing is complete' do
        before { described_class.process(contagion) }

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
        expect { described_class.process(contagion) }
          .not_to(change { contagion.reload.instants.count })
      end

      it do
        expect { described_class.process(contagion) }
          .to change { created_instant.reload.status }
          .from(Simulation::Contagion::Instant::CREATED)
          .to(Simulation::Contagion::Instant::READY)
      end

      it do
        expect { described_class.process(contagion) }
          .not_to(change { created_instant.reload.populations.count })
      end

      it do
        expect { described_class.process(contagion) }
          .to change { created_instant.reload.populations.map(&:state) }
          .from(%w[healthy infected])
          .to(%w[healthy immune])
      end

      context 'when processing is complete' do
        before { described_class.process(contagion) }

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
          size: 1,
          days: infected_days
        )
      end

      it 'creates a new instant' do
        expect { described_class.process(contagion) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      it 'creates a new ready instant' do
        described_class.process(contagion)

        expect(created_instant.status)
          .to eq(Simulation::Contagion::Instant::READY)
      end

      it 'changes instant status' do
        expect { described_class.process(contagion) }
          .to change { ready_instant.reload.status }
          .from(Simulation::Contagion::Instant::READY)
          .to(Simulation::Contagion::Instant::PROCESSED)
      end

      context 'when death does not start' do
        before { described_class.process(contagion) }

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
      end

      context 'when death kills everyone' do
        let(:days_till_start_death) { 1 }

        before { described_class.process(contagion) }

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
      end

      context 'when death kills no one and and recovery happens' do
        let(:days_till_start_death) { 1 }
        let(:days_till_recovery)    { 1 }
        let(:lethality)             { 0 }

        before { described_class.process(contagion) }

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
      end
    end
  end
end
