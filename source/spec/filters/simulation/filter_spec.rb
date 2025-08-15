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
      
      it 'returns simulations matching the name filter' do
        expect(filter.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the name filter' do
        expect(filter.apply(scope)).not_to include(other_simulation)
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
    end
  end
end