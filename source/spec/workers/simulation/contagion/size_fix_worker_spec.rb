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
      end

      context 'when there is one instant' do
        include_context 'with instant with empty populations', 0

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 0)
        end
      end

      context 'when there is one instant' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 1)
        end
      end
    end

    context 'when day is passed' do
      subject(:perform) do
        described_class.new.perform(simulation.id, day)
      end

      context 'when there is one instant' do
        include_context 'with instant with empty populations', 0

        let(:day) { 0 }

        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end
      end

      context 'when there is one instant and day 1 is passed' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        let(:day) { 1 }

        it do
          perform

          expect(described_class)
            .to have_received(:perform_async)
            .with(simulation.id, 0)
        end
      end

      context 'when there is one instant and day 0 is passed' do
        include_context 'with instant with empty populations', 0
        include_context 'with instant with empty populations', 1
        let(:day) { 0 }

        it do
          perform

          expect(described_class)
            .not_to have_received(:perform_async)
        end
      end
    end
  end
end
