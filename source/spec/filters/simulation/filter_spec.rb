# frozen_string_literal: true

RSpec.describe Simulation::Filter, type: :model do
  describe '#apply' do
    let(:scope) { Simulation.all }
    
    context 'when no filters are provided' do
      subject(:filter) { described_class.new }
      
      it 'returns the original scope unchanged' do
        expect(filter.apply(scope)).to eq(scope)
      end
    end
  end
end