# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::Processor do
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

  before { contagion.reload }

  describe '.process' do
    context 'when there are no instants' do
      let(:infected)              { 1 }
      let(:lethality)             { 1 }
      let(:days_till_start_death) { 0 }

      it do
        expect { described_class.process(contagion) }
          .to change { contagion.reload.instants.count }
          .by(1)
      end

      context 'when processing is complete' do
        before { described_class.process(contagion) }

        it 'generates populations' do
          expect(instant.populations.size).to eq(2)
        end

        it 'sets correct status of instant' do
          expect(instant.status)
            .to eq(Simulation::Contagion::Instant::CREATED)
        end
      end
    end
  end
end
