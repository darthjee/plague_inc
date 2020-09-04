# frozen_string_literal: true

require 'spec_helper'

describe ContagionController do
  let(:simulation) { create(:simulation, status: status) }
  let(:contagion)  { simulation.contagion }

  let(:status) do
    Simulation::STATUSES.sample
  end

  describe 'GET summary' do
    let(:parameters) do
      {
        simulation_id: simulation.id
      }
    end

    let(:expected_instants) { instants }

    let(:decorator) do
      Simulation::Contagion::SummaryDecorator.new(
        simulation, expected_instants
      )
    end

    let(:expected_json) do
      decorator.to_json
    end

    let!(:instants) { [] }

    before do
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
end
