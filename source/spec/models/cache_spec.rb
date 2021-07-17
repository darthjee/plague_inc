# frozen_string_literal: true

require 'spec_helper'

fdescribe Cache do
  subject(:cache) { described_class.new(configs) }
  
  let(:configs) { Set.new(classes) }
  let(:classes) do
    [
      Simulation::Contagion::Group,
      Simulation::Contagion::Behavior,
    ]
  end

  describe '#find' do
    let(:klass) { Simulation::Contagion::Group }

    let(:simulation) { create(:simulation, :processing) }
    let(:contagion)  { simulation.contagion }
    let(:group_id)   { group.id }
    let!(:group)     { contagion.groups.last }

    let!(:instant) do
      create(
        :contagion_instant,
        contagion: contagion
      )
    end

    let(:population) do
      create(
        :contagion_population,
        instant: instant, group: group
      )
    end

    it 'returns correct given group' do
      expect(cache.find(:group, group_id))
        .to eq(group)
    end

    context 'when cache has been requested before' do
      before do
        allow(klass)
          .to receive(:find)
          .with(group_id)
          .and_return(group).once

        cache.find(:group, group_id)
      end

      it do
        cache.find(:group, group_id)

        expect(klass).to have_received(:find).once
      end
    end

    context 'when cache has been requested before from relation' do
      before do
        allow(klass)
          .to receive(:find)
          .with(group_id)
          .and_return(group).once

        cache.fetch_from(:group, population)
      end

      it do
        cache.find(:group, group_id)

        expect(klass).to have_received(:find).once
      end
    end
  end

  describe '[]' do
    context 'when class has been set' do
      context 'when key is the class' do
        let(:key) { classes.sample }

        it do
          expect(cache[key]).to be_a(CacheStore)
        end

        it "returns correct cache store" do
          expect(cache[key]).to eq(CacheStore.new(key))
        end
      end

      context 'when key is the class' do
        let(:key) { :group }

        it do
          expect(cache[key]).to be_a(CacheStore)
        end

        it "returns correct cache store" do
          expect(cache[key])
            .to eq(CacheStore.new(Simulation::Contagion::Group))
        end
      end
    end

    context 'when class has not been set' do
      context 'when key is the class' do
        let(:key) { Simulation::Contagion }

        it do
          expect(cache[key]).to be_nil
        end
      end

      context 'when key is the class' do
        let(:key) { :contagion }

        it do
          expect(cache[key]).to be_nil
        end
      end
    end
  end
end

