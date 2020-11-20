# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::CacheWarmer, :contagion_cache do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { group.behavior }
  let(:loaded_instant) do
    Simulation::Contagion::Instant.find(instant.id)
  end

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  let!(:population) do
    create(
      :contagion_population,
      instant:  instant,
      group:    group,
      behavior: behavior
    )
  end

  describe '.process' do
    let(:process) do
      described_class.process(loaded_instant, cache: cache)
    end

    it do
      expect(described_class.process(loaded_instant, cache: cache))
        .to eq(instant)
    end

    context 'when population didnt have the right group loaded' do
      before do
        loaded_instant.populations[0].group.name = 'Other Name'
      end

      it do
        expect { process }
          .to change { loaded_instant.populations[0].group.name }
          .from('Other Name')
          .to(group.name)
      end
    end

    context 'when population didnt have the right behavior loaded' do
      before do
        loaded_instant.populations[0].behavior.name = 'Other Name'
      end

      it do
        expect { process }
          .to change { loaded_instant.populations[0].behavior.name }
          .from('Other Name')
          .to(behavior.name)
      end
    end

    context 'when group didnt have the right behavior loaded' do
      before do
        cache[:group].fetch_from(loaded_instant.populations[0])
        loaded_instant.populations[0].group.behavior.name = 'Other Name'
      end

      it do
        expect { process }
          .to change { loaded_instant.populations[0].group.behavior.name }
          .from('Other Name')
          .to(behavior.name)
      end
    end
  end
end
