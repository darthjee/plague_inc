# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Group::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:decorator_json) { JSON.parse(decorator.to_json) }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object) { build(:contagion_group) }

      let(:expected_json) do
        object
          .as_json
          .slice('name', 'size', 'reference')
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is invalid but object has not been validated' do
        let(:object) do
          build(:contagion_group, size: nil)
        end

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is invalid and object has been validated' do
        let(:object) do
          build(:contagion_group, size: nil)
        end

        let(:expected_errors) do
          {
            "size"=>["can't be blank", "is not a number"]
          }
        end

        let(:expected_json) do
          object
            .as_json
            .slice('name', 'size', 'reference')
            .merge('errors' => expected_errors)
        end

        before { object.valid? }

        it 'returns expected json with errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end

    context 'when object is a collection' do
      let(:object) { build_list(:contagion_group, 3) }

      let(:expected_json) do
        object.map do |group|
          group
            .as_json
            .slice('name', 'size', 'reference')
        end.as_json
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is a collection of invalid not validated objects' do
        let(:object) { build_list(:contagion_group, 3, size: nil) }

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is a collection with invalid ivalidated objects' do
        before { object.each(&:valid?) }

        let(:expected_errors) do
          {
            "size"=>["can't be blank", "is not a number"]
          }
        end

        let(:object) { build_list(:contagion_group, 3, size: nil) }

        let(:expected_json) do
          object.map do |group|
            group
              .as_json
              .slice('name', 'size', 'reference')
              .merge(errors: expected_errors)
          end.as_json
        end

        it 'returns expected json' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end
  end
end

