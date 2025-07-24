# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Killer, :contagion_cache do
  let!(:simulation) { create(:simulation, contagion: contagion) }
  let(:contagion) do
    build(:contagion, simulation: nil, lethality: lethality)
  end

  let(:group) { contagion.reload.groups.last }

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  let(:state) { :infected }

  before do
    [9, 10, 11].map do |day|
      create(
        :contagion_population,
        group: group,
        behavior: group.behavior,
        instant: instant,
        days: day,
        size: day,
        state: state
      )
    end

    simulation.contagion.reload
  end

  describe '.process' do
    context 'when lethality is 100%' do
      let(:lethality) { 1 }

      it 'kills everyone ready to be killed' do
        expect { described_class.process(instant, cache: cache) }
          .to change { instant.populations.pluck(:size) }
          .from([9, 10, 11])
          .to([9, 0, 0, 21])
      end

      it 'does not persist killing' do
        expect { described_class.process(instant, cache: cache) }
          .not_to(change { instant.reload.populations.pluck(:size) })
      end

      it 'builds a population' do
        expect { described_class.process(instant, cache: cache) }
          .to change { instant.populations.size }
          .by(1)
      end

      it 'builds a dead population' do
        described_class.process(instant, cache: cache)

        expect(instant.populations.last.state)
          .to eq('dead')
      end

      it 'builds a population with 0 days' do
        described_class.process(instant, cache: cache)

        expect(instant.populations.last.days)
          .to eq(0)
      end

      it 'does not persist new populations' do
        described_class.process(instant, cache: cache)

        expect(instant.populations.last)
          .not_to be_persisted
      end
    end

    context 'when lethality is 100% but populations are not infected' do
      let(:lethality) { 1 }
      let(:state)     { :healthy }

      it 'kills no one' do
        expect { described_class.process(instant, cache: cache) }
          .not_to(change { instant.populations.pluck(:size) })
      end
    end

    context 'when lethality is 0%' do
      let(:lethality) { 0 }

      it 'kills no one' do
        expect { described_class.process(instant, cache: cache) }
          .not_to(change { instant.populations.pluck(:size) })
      end
    end
  end
end
