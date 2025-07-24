# frozen_string_literal: true

require 'spec_helper'

describe Cacheable do
  subject(:cached) { cached_class.new }

  let(:cached_class) do
    Class.new.tap do |clazz|
      clazz.include described_class
      clazz.cache_for(klass)
    end
  end

  let(:klass) { Simulation }

  let(:simulation)    { create(:simulation) }
  let(:simulation_id) { simulation.id }

  describe 'from_cache' do
    it 'fetch object from database' do
      expect(cached.from_cache(:simulation, simulation.id))
        .to eq(simulation)
    end

    context 'when cache has been requested before' do
      before do
        allow(klass)
          .to receive(:find)
          .with(simulation_id)
          .and_return(simulation).once

        cached.from_cache(:simulation, simulation.id)
      end

      it do
        cached.from_cache(:simulation, simulation.id)

        expect(klass).to have_received(:find).once
      end
    end
  end

  describe 'with_cache' do
    let(:contagion)    { simulation.contagion }
    let(:contagion_id) { contagion.id }

    it 'fetch object from database' do
      expect(cached.with_cache(contagion, :simulation))
        .to eq(simulation)
    end

    context 'when cache has been requested before' do
      before do
        allow(klass)
          .to receive(:find)
          .with(simulation_id)
          .and_return(simulation).once

        cached.with_cache(contagion, :simulation)
      end

      it do
        cached.with_cache(contagion, :simulation)

        expect(klass).to have_received(:find).once
      end
    end
  end
end
