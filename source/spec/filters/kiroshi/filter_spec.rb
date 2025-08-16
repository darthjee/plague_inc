# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kiroshi::Filter, type: :model do
  describe '#apply' do
    let(:scope) { Simulation.all }
    let(:filter_value) { 'test_value' }
    let(:filters) { { name: filter_value } }
    let!(:matching_simulation) { create(:simulation, name: filter_value) }
    let!(:non_matching_simulation) { create(:simulation, name: 'other_value') }

    context 'when match is :exact' do
      subject(:filter) { described_class.new(:name, match: :exact) }

      it 'returns exact matches' do
        expect(filter.apply(scope, filters)).to include(matching_simulation)
      end

      it 'does not return non-matching records' do
        expect(filter.apply(scope, filters)).not_to include(non_matching_simulation)
      end
    end

    context 'when match is :like' do
      subject(:filter) { described_class.new(:name, match: :like) }

      let(:filter_value) { 'test' }
      let!(:matching_simulation) { create(:simulation, name: 'test_simulation') }
      let!(:non_matching_simulation) { create(:simulation, name: 'other_value') }

      it 'returns partial matches' do
        expect(filter.apply(scope, filters)).to include(matching_simulation)
      end

      it 'does not return non-matching records' do
        expect(filter.apply(scope, filters)).not_to include(non_matching_simulation)
      end
    end

    context 'when match is :like' do
      subject(:filter) { described_class.new(:name, match: :like) }

      let(:filter_value) { 'test' }
      let!(:matching_simulation) { create(:simulation, name: 'test_simulation') }
      let!(:non_matching_simulation) { create(:simulation, name: 'other_value') }

      it 'returns partial matches' do
        expect(filter.apply(scope, filters)).to include(matching_simulation)
      end

      it 'does not return non-matching records' do
        expect(filter.apply(scope, filters)).not_to include(non_matching_simulation)
      end
    end

    context 'when match is not specified (default)' do
      subject(:filter) { described_class.new(:name) }

      it 'defaults to exact match' do
        result = filter.apply(scope, filters)
        expect(result).to include(matching_simulation)
        expect(result).not_to include(non_matching_simulation)
      end
    end

    context 'when match is not specified (default)' do
      subject(:filter) { described_class.new(:name) }

      it 'defaults to exact match' do
        result = filter.apply(scope, filters)
        expect(result).to include(matching_simulation)
      end

      it 'does not return non-matching records' do
        result = filter.apply(scope, filters)
        expect(result).not_to include(non_matching_simulation)
      end
    end

    context 'when filter value is not present' do
      subject(:filter) { described_class.new(:name) }

      let(:filters) { { name: nil } }

      it 'returns the original scope unchanged' do
        result = filter.apply(scope, filters)
        expect(result).to eq(scope)
      end
    end
  end
end
