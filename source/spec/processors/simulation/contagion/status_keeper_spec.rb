# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::StatusKeeper do
  let(:simulation) { create :simulation }

  describe '.process' do
    let(:block) { proc { test_double.process } }

    let(:test_double) { processor_class.new }

    let(:processor_class) do
      Class.new do
        def process
        end
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
