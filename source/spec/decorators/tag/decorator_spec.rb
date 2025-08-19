# frozen_string_literal: true

require 'spec_helper'

describe Tag::Decorator do
  subject(:decorator) { described_class.new(object) }

  let(:attributes) { %w[name] }
  let(:decorator_json) { JSON.parse(decorator.to_json) }

  describe '#to_json' do
    context 'when object is one entity' do
      let(:object) { create(:tag) }

      let(:expected_json) do
        object
          .as_json
          .slice(*attributes)
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is invalid but object has not been validated' do
        let(:object) { build(:tag, name: nil) }

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is invalid and object has been validated' do
        let(:object) { build(:tag, name: nil) }

        let(:expected_errors) do
          {
            name: ["can't be blank"]
          }
        end

        let(:expected_json) do
          object
            .as_json
            .slice(*attributes)
            .merge(errors: expected_errors)
            .deep_stringify_keys
        end

        before { object.valid? }

        it 'returns expected json with errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end

    context 'when object is a collection' do
      let(:object) { create_list(:tag, 3) }

      let(:expected_json) do
        object.map do |tag|
          tag
            .as_json
            .slice(*attributes)
        end.as_json
      end

      it 'returns expected json' do
        expect(decorator_json).to eq(expected_json)
      end

      context 'when object is a collection of invalid not validated objects' do
        let(:object) { build_list(:tag, 3, name: nil) }

        it 'returns expected json without errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end

      context 'when object is a collection with invalid validated objects' do
        let(:object) { build_list(:tag, 3, name: nil) }

        let(:expected_errors) do
          {
            name: ["can't be blank"]
          }
        end

        let(:expected_json) do
          object.map do |tag|
            tag
              .as_json
              .slice(*attributes)
              .merge(errors: expected_errors)
          end.as_json
        end

        before { object.each(&:valid?) }

        it 'returns expected json with errors' do
          expect(decorator_json).to eq(expected_json)
        end
      end
    end
  end
end