# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Enqueue do
  let(:quantity) { Random.rand(5..10) }

  let(:initial_schedules)  { [] }
  let(:critical_schedules) { [] }
  let(:schedules)          { [] }

  let(:created_simulations) do
    Simulation.where(status: :created)
  end

  let(:processing_simulations) do
    Simulation.where(status: %i[processing processed])
  end

  before do
    quantity.times do
      Simulation::STATUSES.each do |status|
        create(:simulation, status: status)
      end
    end
  end

  describe '.process' do
    before do
      allow(Simulation::ProcessorInitialWorker)
        .to receive(:perform_async) do |id|
          initial_schedules << id
        end
      allow(Simulation::ProcessorCriticalWorker)
        .to receive(:perform_async) do |id|
          critical_schedules << id
        end
      allow(Simulation::ProcessorWorker)
        .to receive(:perform_async) do |id|
          schedules << id
        end

      described_class.process
    end

    it 'schedules the processed/processing simulations' do
      expect(critical_schedules + schedules)
        .to match_array(processing_simulations.pluck(:id))
    end

    it 'schedules half as critical' do
      expect(critical_schedules.size)
        .to eq(schedules.size)
    end

    it 'schedules created simulations' do
      expect(initial_schedules)
        .to match_array(created_simulations.pluck(:id))
    end
  end
end
