# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Simulation::Filter, type: :model do
  describe '#apply' do
    subject(:filter) { described_class.new(filter_hash) }

    let(:scope) { Simulation.all }
    let(:attributes) { {} }
    let(:other_attributes) { {} }
    let!(:simulation) { create(:simulation, **attributes) }
    let!(:other_simulation) { create(:simulation, **other_attributes) }

    context 'when no filters are provided' do
      let(:filter_hash) { {} }

      it 'returns the original scope unchanged' do
        expect(filter.apply(scope)).to eq(scope)
      end
    end

    context 'when filtering by name' do
      let(:filter_name) { 'Covid Simulation' }
      let(:attributes) { { name: filter_name } }
      let(:other_attributes) { { name: 'Flu Simulation' } }

      let(:filter_hash) { { name: filter_name } }

      context 'when it is an exact match' do
        it 'returns simulations matching the name filter' do
          expect(filter.apply(scope)).to include(simulation)
        end

        it 'does not return simulations not matching the name filter' do
          expect(filter.apply(scope)).not_to include(other_simulation)
        end
      end

      context 'when it is not an exact match' do
        let(:filter_name) { 'Covid' }
        let(:attributes) { { name: 'Covid Simulation' } }

        it 'returns simulations that partially match the name filter' do
          expect(filter.apply(scope)).to include(simulation)
        end

        it 'does not return simulations that do not match the name filter' do
          expect(filter.apply(scope)).not_to include(other_simulation)
        end
      end
    end

    context 'when filtering by status' do
      let(:filter_status) { 'finished' }
      let(:attributes) { { status: filter_status } }
      let(:other_attributes) { { status: 'processing' } }

      let(:filter_hash) { { status: filter_status } }

      it 'returns simulations matching the status filter' do
        expect(filter.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the status filter' do
        expect(filter.apply(scope)).not_to include(other_simulation)
      end

      context 'when it is not an exact match' do
        let(:filter_status) { 'fin' }
        let(:attributes) { { status: 'finished' } }

        it 'does not return simulations that partially match the status filter' do
          expect(filter.apply(scope)).not_to include(simulation)
        end

        it 'does not return simulations that do not match the status filter' do
          expect(filter.apply(scope)).not_to include(other_simulation)
        end
      end
    end
    
    context 'when filtering by tag name' do
      let(:tag_name) { 'epidemic' }
      let(:tag) { create(:tag, name: tag_name) }
      let(:other_tag) { create(:tag, name: 'pandemic') }
      let(:attributes) { { tags: [tag.name] } }
      let(:other_attributes) { { tags: [other_tag.name] } }
      let(:scope) { Simulation.joins(:tags) }

      let(:filter_hash) { { tag_name: tag_name } }

      it 'returns simulations matching the tag name filter' do
        expect(filter.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the tag name filter' do
        expect(filter.apply(scope)).not_to include(other_simulation)
      end

      context 'when it is not an exact match' do
        let(:tag_name) { 'epi' }
        let(:tag) { create(:tag, name: 'epidemic') }

        it 'returns simulations that partially match the tag name filter' do
          expect(filter.apply(scope)).to include(simulation)
        end

        it 'does not return simulations that do not match the tag name filter' do
          expect(filter.apply(scope)).not_to include(other_simulation)
        end
      end
    end
  end
end
