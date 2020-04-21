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
        let(:object) do
          build(:simulation, name: nil, algorithm: 'invalid')
        end

        context "when object has not been validated" do
          it 'returns expected json without errors' do
            expect(decorator.to_json).to eq(expected_json)
          end
        end

        context "when object has been validated" do
          before { object.valid? }

          let(:expected_errors) do
            {
              name: ["can't be blank"],
              algorithm: ['is not included in the list']
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
    end

    context 'when object is a collection' do
      let(:object) { build_list(:simulation, 3) }

      let(:expected_json) do
        object.map do |simulation|
          simulation.as_json.slice(*attributes)
        end.to_json
      end

      it 'returns expected json' do
        expect(decorator.to_json).to eq(expected_json)
      end

      context 'when object is a collection with invalid objects' do
        context "when objects have not been validated" do
          it 'returns expected json without errors' do
            expect(decorator.to_json).to eq(expected_json)
          end
        end

        context "when objects have been validated" do
          before { object.each(&:valid?) }

          let(:expected_errors) do
            {
              name: ["can't be blank"],
              algorithm: [
                "can't be blank",
                'is not included in the list'
              ]
            }
          end

          let(:object) { build_list(:simulation, 3, name: nil, algorithm: nil) }

          let(:expected_json) do
            object.map do |simulation|
              simulation
                .as_json
                .slice(*attributes)
                .merge(errors: expected_errors)
            end.to_json
          end


          it 'returns expected json' do
            expect(decorator.to_json).to eq(expected_json)
          end
        end
      end
    end
  end
end
