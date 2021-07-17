# frozen_string_literal: true

require 'spec_helper'

describe Cache do
  subject(:cache) { described_class.new(configs) }

  let(:configs) { Set.new(classes) }
  let(:classes) do
    [
      Simulation::Contagion::Group,
      Simulation::Contagion::Behavior,
    ]
  end

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

  describe '#find' do
    let(:klass) { Simulation::Contagion::Group }

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

  describe '#fetch_from' do
    let(:klass)       { Simulation::Contagion::Behavior }
    let(:behavior)    { group.behavior }
    let(:behavior_id) { behavior.id }
    let(:other_behavior) do
      create(:contagion_behavior, contagion: contagion)
    end

    it 'returns correct given group' do
      expect(cache.fetch_from(:behavior, group))
        .to eq(behavior)
    end

    context 'when returned value is different from current object value' do
      before do
        allow(klass)
          .to receive(:find)
          .with(behavior_id)
          .and_return(other_behavior).once
      end

      it 'assign attribute' do
        expect { cache.fetch_from(:behavior, group) }
          .to change(group, :behavior)
          .from(behavior)
          .to(other_behavior)
      end
    end

    context 'when cache has been requested before' do
      before do
        allow(klass)
          .to receive(:find)
          .with(behavior_id)
          .and_return(behavior).once

        cache.find(:behavior, behavior_id)
      end

      it do
        cache.fetch_from(:behavior, group)

        expect(klass).to have_received(:find).once
      end
    end

    context 'when cache has been requested before from relation' do
      before do
        allow(klass)
          .to receive(:find)
          .with(behavior_id)
          .and_return(behavior).once

        cache.fetch_from(:behavior, group)
      end

      it do
        cache.fetch_from(:behavior, group)

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

