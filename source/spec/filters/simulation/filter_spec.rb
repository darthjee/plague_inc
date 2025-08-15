# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Simulation::Filter, type: :model do
  describe '#apply' do
    let(:scope) { Simulation.all }
    
    context 'when no filters are provided' do
      subject(:filter) { described_class.new }
      
      it 'returns the original scope unchanged' do
        expect(filter.apply(scope)).to eq(scope)
      end
    end

    context 'when filter by name' do
      let(:filter_name) { 'Covid Simulation' }
      let!(:simulation) { create(:simulation, name: filter_name) }
      let!(:other_simulation) { create(:simulation, name: 'Flu Simulation') }
      
      subject(:filter) { described_class.new(name: filter_name) }
      
      it 'returns simulations matching the name filter' do
        expect(filter.apply(scope)).to include(simulation)
      end

      it 'does not return simulations not matching the name filter' do
        expect(filter.apply(scope)).not_to include(other_simulation)
      end
    end
  end
end