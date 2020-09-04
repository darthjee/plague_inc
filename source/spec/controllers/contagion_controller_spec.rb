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

    let!(:expected_instants) { [] }

    let(:decorator) do
      Simulation::Contagion::SummaryDecorator.new(
        simulation, expected_instants
      )
    end

    let(:expected_json) do
      decorator.to_json
    end

    before do
      get :summary, params: parameters
    end

    context 'when simulation has no instants' do
      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'simulation has instants' do
      let(:instants) { 3 }

      let!(:expected_instants) do
        instants.times.map do |day|
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

    context 'simulation has more instants than pagination' do
      let(:instants) do
        Settings.contagion_instants_pagination + 2
      end

      let!(:expected_instants) do
        instants.times.map do |day|
          create(
            :contagion_instant,
            contagion: contagion,
            day: day
          )
        end.take(Settings.contagion_instants_pagination)
      end

      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'simulation has more instants than pagination' do
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

      let!(:expected_instants) do
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
  end
end
