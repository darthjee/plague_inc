require 'spec_helper'

describe CacheStore do
  subject(:store) { described_class.new(klass) }

  let(:klass) { Simulation::Contagion::Group }

  let(:simulation) { create(:simulation, :processing) }
  let(:contagion)  { simulation.contagion }
  let(:group_id)   { group.id }

  let!(:group) { contagion.groups.last }

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
  end

  describe '#fetch_from' do
    let(:klass)       { Simulation::Contagion::Behavior }
    let(:behavior)    { group.behavior }
    let(:behavior_id) { behavior.id }

    it 'returns correct given group' do
      expect(store.fetch_from(group))
        .to eq(behavior)
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
  end
end
