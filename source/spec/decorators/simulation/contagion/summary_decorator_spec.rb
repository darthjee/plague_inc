# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::SummaryDecorator do
  subject(:decorator) do
    described_class.new(simulation, instants)
  end

  let(:simulation) do
    create(
      :simulation,
      status: status,
      created_at: created_at,
      updated_at: updated_at
    )
  end

  let(:contagion) { simulation.contagion }
  let(:group)     { contagion.groups.first }
  let(:behavior)  { contagion.behaviors.first }
  let(:instants)  { [instant] }

  let(:status)     { Simulation::STATUSES.sample }
  let(:created_at) { 2.days.ago }
  let(:updated_at) { 1.second.ago }
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
          stale: false,
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
          stale: false,
          instants: [{
            id: instant.id,
            status: instant.status,
            day: day,
            dead: 0,
            healthy: 0,
            immune: 0,
            infected: 0,
            total: 0
          }]
        }.as_json
      end

      it 'returns simulation with instant instants' do
        expect(decorator.as_json).to eq(expected)
      end
    end

    context 'when simulation is processing' do
      let(:status)   { Simulation::PROCESSING }
      let(:instants) { [] }

      context 'when it has been updated recently' do
        let(:expected) do
          {
            status: simulation.status,
            stale: false,
            instants: []
          }.as_json
        end

        it 'returns simulation not stale' do
          expect(decorator.as_json).to eq(expected)
        end
      end

      context 'when it hasnt been updated recently' do
        let(:updated_at) { 10.minutes.ago }
        let(:expected) do
          {
            status: simulation.status,
            stale: true,
            instants: []
          }.as_json
        end

        it 'returns simulation not stale' do
          expect(decorator.as_json).to eq(expected)
        end
      end
    end
  end
end
