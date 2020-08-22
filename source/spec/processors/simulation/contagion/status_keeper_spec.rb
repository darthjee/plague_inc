# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::StatusKeeper do
  let(:simulation) { create :simulation }
  let(:contagion)  { simulation.contagion }
  let(:group)      { contagion.groups.last }
  let(:behavior)   { contagion.behaviors.last }

  describe '.process' do
    let(:block) { proc { test_double.process } }
    let!(:current_instant) do
      create(
        :contagion_instant, :ready,
        contagion: contagion,
        day: 0,
        populations: current_populations
      )
    end

    let(:current_states) do
      %i[infected healthy dead immune]
    end

    let(:current_populations) do
      current_states.map do |state|
        build(
          :contagion_population, state,
          group: group,
          behavior: behavior,
          instant: nil
        )
      end
    end

    let(:test_double) { processor_class.new }

    let(:processor_class) do
      Class.new do
        def process; end
      end
    end

    before do
      allow(test_double).to receive(:process)
    end

    it do
      described_class.process(simulation, &block)

      expect(test_double).to have_received(:process)
    end

    it do
      expect { described_class.process(simulation, &block) }
        .to change { simulation.reload.status }
        .to(Simulation::PROCESSED)
    end

    context 'when simulation is left with no infected' do
      let(:new_instant) do
        create(
          :contagion_instant, :ready,
          contagion: contagion,
          day: 1,
          populations: new_populations
        )
      end

      let(:new_states) do
        %i[healthy dead immune]
      end

      let(:new_populations) do
        new_states.map do |state|
          build(
            :contagion_population, state,
            group: group,
            behavior: behavior,
            instant: nil
          )
        end
      end

      let(:block) do
        proc do
          current_instant.update(
            status: Simulation::Contagion::Instant::PROCESSED
          )
          new_instant
        end
      end

      it do
        expect { described_class.process(simulation, &block) }
          .to change { simulation.reload.status }
          .to(Simulation::FINISHED)
      end
    end

    context 'when block call raises an exception' do
      before do
        allow(test_double).to receive(:process)
          .and_raise(Mysql2::Error::ConnectionError.new('failed'))
      end

      it do
        expect { described_class.process(simulation, &block) }
          .to raise_error(Mysql2::Error::ConnectionError)
          .and change { simulation.reload.status }
          .to(Simulation::PROCESSING)
      end
    end
  end
end
