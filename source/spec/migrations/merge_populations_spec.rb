# frozen_string_literal: true

require 'spec_helper'

describe MergePopulations do
  let(:simulation) { create(:simulation, :processing) }
  let(:contagion)  { simulation.contagion }
  let!(:instant) do
    create(:contagion_instant, contagion: contagion, day: 0)
  end

  let(:group)       { contagion.groups.last }
  let(:behavior)    { group.behavior }
  let(:populations) { instant.populations }

  let(:filtered_populations) do
    instant.populations.where(state: state)
  end

  let(:final_populations) { filtered_populations.where(days: base_days) }

  describe '.process' do
    let(:all_states) { Simulation::Contagion::Population::STATES }
    let(:state)      { all_states .sample }
    let(:base_days)  { Random.rand(10) }

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

    let(:expected_target_size) do
      target_populations.map(&:size).sum
    end

    let(:expected_other_size) do
      other_group_populations.map(&:size).sum
    end

    let!(:expected_sizes) do
      [expected_target_size, expected_other_size]
    end

    let(:process) { described_class.process(state: state) }

    let!(:other_state_populations) do
      other_states.map do |state|
        populations_count.times.map do |days|
          create(
            :contagion_population,
            state: state,
            group: group,
            behavior: behavior,
            size: Random.rand(10..100),
            instant: instant,
            interactions: 10,
            days: days + base_days
          )
        end
      end
    end

    let(:other_group_populations) do
      populations_count.times.map do |days|
        create(
          :contagion_population,
          state: state,
          group: other_group,
          behavior: behavior,
          size: Random.rand(10..100),
          instant: instant,
          interactions: 10,
          days: days + base_days
        )
      end
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
          days: days + base_days
        )
      end
    end

    before do
      other_state_populations
      other_group_populations
    end

    it 'merge populations for each group' do
      expect { process }
        .to change { instant.populations.size }
        .by(2 - 2 * populations_count)
    end

    it 'merge populations size for each group' do
      expect { process }
        .to change { final_populations.reload.pluck(:size) }
        .to(expected_sizes)
    end
  end
end
