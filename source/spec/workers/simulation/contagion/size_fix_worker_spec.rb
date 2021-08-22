# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::SizeFixWorker do
  describe '.enqueue_all' do
    let(:quantity) { Random.rand(2..4) }

    let!(:simulations) do
      create_list(:simulation, quantity)
    end

    let(:called_ids) { [] }

    before do
      allow(described_class)
        .to receive(:perform_async) do |*args|
          called_ids << args
        end
    end

    it 'enqueue a fix for each simulation' do
      described_class.enqueue_all

      expect(called_ids.flatten).to eq(simulations.pluck(:id))
    end
  end

  describe '#perform' do
    subject(:perform) do
      described_class.new.perform(simulation.id)
    end

    let(:simulation) { create(:simulation) }
    let(:contagion)  { simulation.contagion }
    let(:group)      { contagion.groups.first }
    let(:behavior)   { contagion.behaviors.first }

    before do
      allow(described_class)
        .to receive(:perform_async)
    end

    context 'when day is not passed' do
      context 'when there is no instant' do
        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end

        it do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end
      end

      context 'when there is one instant' do
        include_context 'with instant with empty populations', 0

        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end

        it do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end
      end

      context 'when there are two instant' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 1)
        end

        it do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end
      end

      context 'when there are three instant' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        include_context 'with instant with empty populations', 2

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 2)
        end

        it do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end
      end
    end

    context 'when day is passed' do
      subject(:perform) do
        described_class.new.perform(simulation.id, day)
      end

      context 'when there are two instants and day 1 is passed' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        let(:day) { 1 }

        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end

        it do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-1)
        end
      end

      context 'when there are three instant and day 1 is passed' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        include_context 'with instant with empty populations', 2
        let(:day) { 1 }

        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end

        it do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-1)
        end
      end

      context 'when there are three instant and day 2 is passed' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        include_context 'with instant with empty populations', 2
        let(:day) { 2 }

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 1)
        end

        it do
          expect { perform }
            .to change(Simulation::Contagion::Population, :count)
            .by(-1)
        end
      end

      context 'when there healthy population is not empty' do
        include_context 'with instant with empty populations', 0, size: 10
        include_context 'with instant with empty populations', 1, size: 10
        include_context 'with instant with empty populations', 2, size: 10
        let(:day) { 2 }

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 1)
        end

        it do
          expect { perform }
            .not_to change(Simulation::Contagion::Population, :count)
        end
      end
    end
  end
end
