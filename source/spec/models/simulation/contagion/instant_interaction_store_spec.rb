# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::InstantInteractionStore do
  subject(:store) { described_class.new(instant) }

  let(:random_box)  { RandomBox.instance }
  let(:simulation)  { create(:simulation) }
  let(:contagion)   { simulation.contagion }
  let(:instant)     { create(:contagion_instant, contagion: contagion) }
  let(:populations) { instant.populations }

  let(:group) do
    create(
      :contagion_group,
      behavior: behavior,
      contagion: contagion
    )
  end

  let(:behavior) do
    create(
      :contagion_behavior,
      contagion: contagion,
      interactions: behavior_interactions
    )
  end

  let!(:infected_population) do
    create(
      :contagion_population,
      :infected,
      group: group,
      behavior: behavior,
      instant: instant,
      size: infected_size,
      interactions: infected_interactions
    )
  end

  let!(:healthy_population) do
    create(
      :contagion_population,
      :healthy,
      group: group,
      behavior: behavior,
      instant: instant,
      size: healthy_size
    )
  end

  let(:behavior_interactions) { 10 }
  let(:infected_size)         { 1 }
  let(:healthy_size)          { 10 }
  let(:infected_interactions) do
    infected_size * behavior_interactions - 1
  end
  let(:healthy_interactions) do
    healthy_size * behavior_interactions
  end
  let(:total_interactions) do
    healthy_interactions + infected_interactions
  end

  before do
    allow(random_box)
      .to receive(:interaction) do
      random_interactions.shift
    end
  end

  context "when random choice falls within healthy population" do
    let(:random_interactions) { [healthy_interactions - 1] }

    it 'register an interaction for healthy_population' do
      expect { store.interact }
        .to change(store, :interaction_map)
        .to({ healthy_population => 1 })
    end

    it 'consumes healthy population interactions' do
      expect { store.interact }
        .to change { populations[0].interactions }
        .by(-1)
    end

    it 'does not persist change' do
      expect { store.interact }
        .not_to change { populations.reload[0].interactions }
    end

    it do
      store.interact

      expect(random_box)
        .to have_received(:interaction)
        .with(total_interactions).once
    end
  end

  context "when random choice falls within infected population" do
    let(:random_interactions) { [healthy_interactions] }
    let(:infected_size)       { 2 }

    it 'register an interaction for healthy_population' do
      expect { store.interact }
        .to change(store, :interaction_map)
        .to({ infected_population => 1 })
    end

    it 'consumes infected population interactions' do
      expect { store.interact }
        .to change { populations[1].interactions }
        .by(-1)
    end

    it 'does not persist change' do
      expect { store.interact }
        .not_to change { populations.reload[1].interactions }
    end

    it do
      store.interact

      expect(random_box)
        .to have_received(:interaction)
        .with(total_interactions).once
    end
  end

  context 'when it is called twice' do
    let(:behavior_interactions) { 1 }
    let(:infected_size)         { 10 }
    let(:healthy_size)          { 1 }

    context 'when first call consumes interactions of one population' do
      let(:random_interactions) { [0, 0] }

      let(:expected_interactions) do
        {
          healthy_population => 1,
          infected_population => 1
        }
      end

      it 'register an interaction for healthy_population' do
        expect { 2.times { store.interact } }
          .to change(store, :interaction_map)
          .to(expected_interactions)
      end

      it 'consumes healthy population interactions' do
        expect { 2.times { store.interact } }
          .to change { populations[0].interactions }
          .by(-1)
      end

      it 'does not persist change on healthy population' do
        expect { 2.times { store.interact } }
          .not_to change { populations.reload[0].interactions }
      end

      it 'consumes infected population interactions' do
        expect { 2.times { store.interact } }
          .to change { populations[1].interactions }
          .by(-1)
      end

      it 'does not persist change on infected population' do
        expect { 2.times { store.interact } }
          .not_to change { populations.reload[1].interactions }
      end

      it do
        2.times { store.interact }

        expect(random_box)
          .to have_received(:interaction)
          .with(total_interactions).once
      end

      it do
        2.times { store.interact }

        expect(random_box)
          .to have_received(:interaction)
          .with(total_interactions - 1).once
      end
    end
  end
end
