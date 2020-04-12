# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:attributes) { %w[id name] }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object) { create(:simulation) }
      let(:expected_json) do
        object.as_json.slice(*attributes).to_json
      end

      it 'returns expected json' do
        expect(decorator.to_json).to eq(expected_json)
      end
    end

    context 'when object is a collection' do
      let(:object) { Simulation.all }
      let(:expected_json) do
        object.map do |simulation|
          simulation.as_json.slice(*attributes)
        end.to_json
      end

      before { create_list(:simulation, 3) }

      it 'returns expected json' do
        expect(decorator.to_json).to eq(expected_json)
      end
    end
  end
end
