# frozen_string_literal: true

require 'spec_helper'

describe Cache::Store do
  subject(:store) { described_class.new(klass) }

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

  describe '#put' do
    before do
      allow(klass)
        .to receive(:find)
        .with(group_id)
        .and_return(group)
    end

    it 'stores a value' do
      store.put(group)
      store.find(group_id)

      expect(klass).not_to have_received(:find)
    end
  end

  describe '#key' do
    it 'returns the name of the class' do
      expect(store.key).to eq('group')
    end
  end

  describe '#find' do
    it 'returns correct given group' do
      expect(store.find(group_id))
        .to eq(group)
    end

    context 'when cache has been requested before' do
      before do
        allow(klass)
          .to receive(:find)
          .with(group_id)
          .and_return(group).once

        store.find(group_id)
      end

      it do
        store.find(group_id)

        expect(klass).to have_received(:find).once
      end
    end

    context 'when cache has been requested before from relation' do
      before do
        allow(klass)
          .to receive(:find)
          .with(group_id)
          .and_return(group).once

        store.fetch_from(population)
      end

      it do
        store.find(group_id)

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
      expect(store.fetch_from(group))
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
        expect { store.fetch_from(group) }
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

        store.find(behavior_id)
      end

      it do
        store.fetch_from(group)

        expect(klass).to have_received(:find).once
      end
    end

    context 'when cache has been requested before from relation' do
      before do
        allow(klass)
          .to receive(:find)
          .with(behavior_id)
          .and_return(behavior).once

        store.fetch_from(group)
      end

      it do
        store.fetch_from(group)

        expect(klass).to have_received(:find).once
      end
    end
  end
end
