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
      let(:expected_instants) { [] }

      it do
        expect(response.body).to eq(expected_json)
      end
    end

    context 'simulation has instants' do
      let!(:expected_instants) do
        3.times.map do |day|
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
  end
end