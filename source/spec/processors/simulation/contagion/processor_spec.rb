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
            .to eq(["dead", "healthy", "infected"])
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
          .not_to change { contagion.reload.instants.count }
      end

      it do
        expect { described_class.process(contagion) }
          .to change { created_instant.reload.status }
          .from(Simulation::Contagion::Instant::CREATED)
          .to(Simulation::Contagion::Instant::READY)
      end

      it do
        expect { described_class.process(contagion) }
          .not_to change { created_instant.reload.populations.count }
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

    xcontext 'when there is a ready instant' do
      let!(:ready_instant) do
        create(:contagion_instant, day: 0, status: :read)
      end
      let(:infected_population) do
        create(
          :contagion_population,
          group: group,
          behavior: behavior,
          size: 1
        )
      end

      it 'adds test here'
    end
  end
end
