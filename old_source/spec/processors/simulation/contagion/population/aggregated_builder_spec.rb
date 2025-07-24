# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Population::AggregatedBuilder do
  let(:simulation) { create(:simulation, :processing) }
  let(:contagion)  { simulation.contagion }
  let(:instant) do
    create(:contagion_instant, contagion: contagion, day: 0)
  end
  let(:new_instant) do
    create(:contagion_instant, contagion: contagion, day: 1)
  end

  let(:group)       { contagion.groups.last }
  let(:behavior)    { group.behavior }
  let(:populations) { instant.populations }

  let(:built_population) do
    described_class.build(
      populations: populations,
      instant: new_instant,
      state: state
    )
  end

  describe '.build' do
    let(:all_states) { Simulation::Contagion::Population::STATES }
    let(:state)      { all_states.sample }

    let(:other_states) do
      all_states - [state]
    end

    let(:other_group) do
      create(
        :contagion_group,
        contagion: contagion,
        behavior: behavior
      )
    end

    let(:populations_count) do
      Random.rand(2..10)
    end

    let(:other_state_populations) do
      other_states.map do |state|
        create(
          :contagion_population,
          state: state,
          group: group,
          behavior: behavior,
          size: Random.rand(10..100),
          instant: instant,
          interactions: 10,
          days: Random.rand(10)
        )
      end
    end

    let(:other_group_population) do
      create(
        :contagion_population,
        state: state,
        group: other_group,
        behavior: behavior,
        size: Random.rand(10..100),
        instant: instant,
        interactions: 10,
        days: Random.rand(10)
      )
    end

    let!(:target_populations) do
      populations_count.times.map do |days|
        create(
          :contagion_population,
          state: state,
          group: group,
          behavior: behavior,
          size: Random.rand(10..100),
          instant: instant,
          interactions: 10,
          days: days
        )
      end
    end

    before do
      other_state_populations
      other_group_population
    end

    it 'builds one population for each group' do
      expect { built_population }
        .to change { new_instant.populations.size }
        .by(2)
    end

    context 'when built is done' do
      before { built_population }

      let(:expected_size) do
        target_populations.map(&:size).sum
      end
      let(:other_size) do
        other_group_population.size
      end

      it do
        expect(new_instant.populations)
          .to all(not_be_persisted)
      end

      it 'groups sizes' do
        expect(new_instant.populations.map(&:size))
          .to eq([expected_size, other_size])
      end
    end
  end
end
