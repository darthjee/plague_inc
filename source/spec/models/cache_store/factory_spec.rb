# frozen_string_literal: true

require 'spec_helper'

describe CacheStore::Factory do
  subject(:factory) { described_class.new }

  describe '#build' do
    it do
      expect(factory.build).to be_a(Hash)
    end

    context 'when nothing has been configured' do
      it { expect(factory.build).to be_empty }
    end

    context 'when factory has been configured' do
      let(:expected) do
        {
          simulation: CacheStore.new(Simulation),
          group: CacheStore.new(Simulation::Contagion::Group)
        }
      end

      before do
        factory.add_cache(Simulation)
        factory.add_cache(Simulation::Contagion::Group)
      end

      it { expect(factory.build).not_to be_empty }

      it 'returns a store for all the configured classes' do
        expect(factory.build).to eq(expected)
      end
    end
  end
end
