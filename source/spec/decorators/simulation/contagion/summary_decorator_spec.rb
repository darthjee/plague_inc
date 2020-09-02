# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::SummaryDecorator do
  subject(:decorator) do
    described_class.new(simulation, instants)
  end

  let(:status)     { Simulation::STATUSES.sample }
  let(:simulation) { create(:simulation, status: status) }
  let(:contagion)  { simulation.contagion }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { contagion.behaviors.first }
  let(:instants)   { [instant] }
  let(:day)        { Random.rand(10) }

  let!(:instant) do
    create(:contagion_instant, contagion: contagion, day: day)
  end

  describe 'as_json' do
    context 'when no instants are given' do
      let(:instants) { [] }

      let(:expected) do
        {
          status: simulation.status,
          instants: []
        }.stringify_keys
      end

      it 'returns simulation with no instants' do
        expect(decorator.as_json).to eq(expected)
      end
    end

    context 'when instants are given' do
      let(:expected) do
        {
          status: simulation.status,
          instants: [{
            day: day,
            dead: 0,
            healthy: 0,
            immune: 0,
            infected: 0,
            total: 0
          }]
        }.as_json
      end

      it 'returns simulation with no instants' do
        expect(decorator.as_json).to eq(expected)
      end
    end
  end
end
