# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kiroshi::Filters, type: :model do
  describe '#apply' do
    subject(:filter_instance) { filters_class.new(filters) }

    let(:scope) { Simulation.all }
    let(:filters) { {} }
    let!(:simulation) { create(:simulation, name: 'test_name', status: 'finished') }
    let!(:other_simulation) { create(:simulation, name: 'other_name', status: 'processing') }

    let(:filters_class) { Class.new(described_class) }

    context 'when no filters are configured' do
      context 'when no filters are provided' do
        it 'returns the original scope unchanged' do
          expect(filter_instance.apply(scope)).to eq(scope)
        end
      end

      context 'when filters are provided' do
        let(:filters) { { name: 'test_name' } }

        it 'returns the original scope unchanged' do
          expect(filter_instance.apply(scope)).to eq(scope)
        end
      end
    end

    context 'when one exact filter is configured' do
      let(:filters) { { name: 'test_name' } }

      before do
        filters_class.filter_by :name
      end

      it 'returns simulations matching the exact filter' do
        expect(filter_instance.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the exact filter' do
        expect(filter_instance.apply(scope)).not_to include(other_simulation)
      end
    end

    context 'when one like filter is configured' do
      let(:filters) { { name: 'test' } }

      before do
        filters_class.filter_by :name, match: :like
      end

      it 'returns simulations matching the like filter' do
        expect(filter_instance.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the like filter' do
        expect(filter_instance.apply(scope)).not_to include(other_simulation)
      end
    end

    context 'when multiple filters are configured' do
      let(:filters) { { name: 'test', status: 'finished' } }

      before do
        filters_class.filter_by :name, match: :like
        filters_class.filter_by :status
      end

      it 'returns simulations matching all filters' do
        expect(filter_instance.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching all filters' do
        expect(filter_instance.apply(scope)).not_to include(other_simulation)
      end
    end

    context 'when filters hash is empty' do
      before do
        filters_class.filter_by :name
        filters_class.filter_by :status
      end

      let(:filters) { {} }

      it 'returns the original scope unchanged' do
        expect(filter_instance.apply(scope)).to eq(scope)
      end
    end
  end
end
