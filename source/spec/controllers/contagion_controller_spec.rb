# frozen_string_literal: true

require 'spec_helper'

describe ContagionController do
  let(:simulation) do
    create(
      :simulation,
      status: status,
      created_at: created_at,
      updated_at: updated_at
    )
  end
  let(:created_at)    { 1.second.ago }
  let(:updated_at)    { 1.second.ago }
  let(:contagion)     { simulation.contagion }
  let(:expected_json) { decorator.to_json }

  let(:status) do
    Simulation::STATUSES.sample
  end

  let(:decorator) do
    Simulation::Contagion::SummaryDecorator.new(
      simulation, expected_instants
    )
  end

  describe 'GET summary' do
    let(:parameters) do
      {
        simulation_id: simulation.id
      }
    end

    let(:expected_instants) { instants }

    let!(:instants) { [] }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Simulation)
        .to receive(:processable_in)
        .and_return(60)
      # rubocop:enable RSpec/AnyInstance

      get :summary, params: parameters
    end

    context 'when simulation has no instants' do
      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when simulation has instants' do
      let(:instants_count) { 3 }

      let(:instants) do
        instants_count.times.map do |day|
          create(
            :contagion_instant,
            contagion: contagion,
            day: day
          )
        end
      end

      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when simulation has more instants than pagination' do
      let(:instants_count) do
        Settings.contagion_instants_pagination + 2
      end

      let(:expected_instants) do
        instants.take(Settings.contagion_instants_pagination)
      end

      let(:instants) do
        instants_count.times.map do |day|
          create(
            :contagion_instant,
            contagion: contagion,
            day: day
          )
        end
      end

      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'with paginating with offset' do
      let(:instants_count) do
        Settings.contagion_instants_pagination + 1
      end

      let(:instants) do
        instants_count.times.map do |day|
          create(
            :contagion_instant,
            contagion: contagion,
            day: day
          )
        end
      end

      let(:first_instant) { instants.first }

      let(:expected_instants) do
        instants[1..Settings.contagion_instants_pagination]
      end

      let(:parameters) do
        {
          simulation_id: simulation.id,
          pagination: {
            last_instant_id: first_instant.id
          }
        }
      end

      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when sending custom pagination' do
      let(:limit) do
        Random.rand(1..Settings.contagion_instants_pagination)
      end

      let(:instants_count) do
        Settings.contagion_instants_pagination + 2
      end

      let!(:instants) do
        instants_count.times.map do |day|
          create(
            :contagion_instant,
            contagion: contagion,
            day: day
          )
        end
      end

      let(:expected_instants) do
        instants.take(limit)
      end

      let(:parameters) do
        {
          simulation_id: simulation.id,
          pagination: {
            limit: limit
          }
        }
      end

      it do
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'POST process' do
    let(:status)     { statuses.sample }
    let(:created_at) { 5.second.ago }
    let(:updated_at) { 5.second.ago }

    let(:statuses) do
      [
        Simulation::CREATED,
        Simulation::PROCESSED
      ]
    end

    context 'when no options are given' do
      let(:parameters) do
        {
          simulation_id: simulation.id
        }
      end

      it do
        expect { post :run_process, params: parameters }
          .to change { simulation.reload.contagion.instants.size }
          .by(Settings.processing_iteractions)
      end

      context 'when the request is done' do
        let(:expected_instants) do
          simulation.reload.contagion.instants
        end

        before { post :run_process, params: parameters }

        it 'returns the created instants' do
          expect(response.body).to eq(expected_json)
        end

        it do
          expect(response).to be_successful
        end
      end

      context 'when simulation is not processable' do
        let(:status)     { Simulation::PROCESSING }
        let(:updated_at) { 1.second.ago }

        it do
          expect { post :run_process, params: parameters }
            .not_to(change { simulation.reload.contagion.instants.size })
        end
      end

      context 'when simulation is not processable after the request' do
        let(:status)            { Simulation::PROCESSING }
        let(:updated_at)        { 1.second.ago }
        let(:expected_instants) { [] }

        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Simulation)
            .to receive(:processable_in)
            .and_return(60)
          # rubocop:enable RSpec/AnyInstance

          post :run_process, params: parameters
        end

        it 'returns the created instants' do
          expect(response.body).to eq(expected_json)
        end

        it do
          expect(response).not_to be_successful
        end
      end

      context 'when there were instants and the request is done' do
        let(:previous_instants_count) { Random.rand(2..4) }

        let(:expected_instants) do
          simulation.reload.contagion.instants
                    .offset(previous_instants_count)
        end

        before do
          previous_instants_count.times do
            Simulation::Processor.process(simulation)
          end

          post :run_process, params: parameters
        end

        it 'returns the created instants' do
          expect(response.body).to eq(expected_json)
        end

        it do
          expect(response).to be_successful
        end
      end
    end

    context 'when times options are given' do
      let(:parameters) do
        {
          simulation_id: simulation.id,
          options: {
            times: times
          }
        }
      end

      let(:times) { Random.rand(2..5) }

      it do
        expect { post :run_process, params: parameters }
          .to change { simulation.reload.contagion.instants.size }
          .by(times)
      end

      it do
        expect(response).to be_successful
      end

      context 'when the request is done' do
        let(:expected_instants) do
          simulation.reload.contagion.instants
        end

        before { post :run_process, params: parameters }

        it 'returns the created instants' do
          expect(response.body).to eq(expected_json)
        end

        it do
          expect(response).to be_successful
        end
      end

      context 'when there were instants and the request is done' do
        let(:previous_instants_count) { Random.rand(2..4) }

        let(:expected_instants) do
          simulation.reload.contagion.instants
                    .offset(previous_instants_count)
        end

        before do
          previous_instants_count.times do
            Simulation::Processor.process(simulation)
          end

          post :run_process, params: parameters
        end

        it 'returns the created instants' do
          expect(response.body).to eq(expected_json)
        end

        it do
          expect(response).to be_successful
        end
      end
    end
  end
end
