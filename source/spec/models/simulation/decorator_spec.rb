# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:attributes) { %w[id name algorithm] }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object) { create(:simulation) }
      let(:expected_json) do
        object.as_json.slice(*attributes).to_json
      end

      it 'returns expected json' do
        expect(decorator.to_json).to eq(expected_json)
      end

      context 'when object is invalid' do
        let(:object)  do
          build(:simulation, name: nil, algorithm: 'invalid')
        end

        let(:expected_errors) do
          {
            name: ["can't be blank"],
            algorithm: ["is not included in the list"]
          }
        end

        let(:expected_json) do
          object
            .as_json
            .slice(*attributes)
            .merge(errors: expected_errors).to_json
        end

        it 'returns expected json with errors' do
          expect(decorator.to_json).to eq(expected_json)
        end
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

      context 'when object is a collection with invalid objects' do
        let(:expected_errors) do
          {
            name: ["can't be blank"],
            algorithm: [
              "can't be blank",
              "is not included in the list"
            ]
          }
        end

        let(:object) do
          Simulation.all.tap do |simulations|
            simulations.each do |simulation|
              simulation.update(name: nil, algorithm: nil)
            end
          end
        end

        let(:expected_json) do
          object.map do |simulation|
            simulation
              .as_json
              .slice(*attributes)
              .merge(errors: expected_errors)
          end.to_json
        end

        before { create_list(:simulation, 2) }

        it 'returns expected json' do
          expect(decorator.to_json).to eq(expected_json)
        end
      end
    end
  end
end
