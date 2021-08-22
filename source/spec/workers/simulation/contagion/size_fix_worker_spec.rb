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
end
