# frozen_string_literal: true

require 'spec_helper'

shared_examples 'a contagion instant summary count of population' do |state|
  let(:result) { decorator.public_send(state) }

  context 'when there is no population' do
    it { expect(result).to be_zero }
  end

  context "when there are only non-#{state} populations" do
    let(:populations) { Random.rand(2..10) }
    let(:states) do
      Simulation::Contagion::Population::STATES -
        [state.to_s]
    end
    let(:sizes) do
      populations.times.map { Random.rand(100..500) }
    end

    before do
      sizes.each.with_index do |size, days|
        create(
          :contagion_population,
          state: states.sample,
          instant: instant,
          group: group,
          behavior: behavior,
          days: days,
          size: size
        )
      end
    end

    it { expect(result).to be_zero }
  end

  context "when there are #{state} and non-#{state} populations" do
    let(:other_populations) { Random.rand(2..10) }
    let(:populations)       { Random.rand(2..10) }
    let(:sizes) do
      populations.times.map { Random.rand(100..500) }
    end
    let(:alive_states) do
      Simulation::Contagion::Population::STATES -
        [state.to_s]
    end

    before do
      other_populations.times.each do |days|
        create(
          :contagion_population,
          state: alive_states.sample,
          instant: instant,
          group: group,
          behavior: behavior,
          days: days
        )
      end

      sizes.each.with_index do |size, days|
        create(
          :contagion_population, state,
          instant: instant,
          group: group,
          behavior: behavior,
          days: days,
          size: size
        )
      end
    end

    it 'returns the sum of dead sizes' do
      expect(result).to eq(sizes.sum)
    end
  end
end

describe Simulation::Contagion::Instant::SummaryDecorator do
  subject(:decorator) { described_class.new(instant) }

  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { contagion.behaviors.first }

  let(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  describe 'as_json' do
    context 'when there are no populations' do
      let(:expected) do
        {
          total: 0,
          dead: 0,
          healthy: 0,
          immune: 0,
          infected: 0
        }.stringify_keys
      end

      it 'returns 0 values' do
        expect(decorator.as_json).to eq(expected)
      end
    end

    context 'when there are populations' do
      let(:states) do
        Simulation::Contagion::Population::STATES
      end

      let(:expected) do
        {
          total: 10,
          dead: 4,
          healthy: 2,
          immune: 3,
          infected: 1
        }.stringify_keys
      end

      before do
        states.each.with_index do |state, size|
          create(
            :contagion_population,
            state: state,
            instant: instant,
            group: group,
            behavior: behavior,
            size: size + 1
          )
        end
      end

      it 'returns the counters values' do
        expect(decorator.as_json).to eq(expected)
      end
    end
  end

  describe '#total' do
    context 'when there is no population' do
      it { expect(decorator.total).to be_zero }
    end

    context 'when there are populations' do
      let(:populations) { Random.rand(2..10) }
      let(:states) do
        Simulation::Contagion::Population::STATES
      end
      let(:sizes) do
        populations.times.map { Random.rand(100..500) }
      end

      before do
        sizes.each.with_index do |size, days|
          create(
            :contagion_population,
            state: states.sample,
            instant: instant,
            group: group,
            behavior: behavior,
            days: days,
            size: size
          )
        end
      end

      it 'returns the sum of all sizes' do
        expect(decorator.total).to eq(sizes.sum)
      end
    end
  end

  describe '#dead' do
    it_behaves_like 'a contagion instant summary count of population', :dead
  end

  describe '#infected' do
    it_behaves_like 'a contagion instant summary count of population', :infected
  end

  describe '#immune' do
    it_behaves_like 'a contagion instant summary count of population', :immune
  end

  describe '#healthy' do
    it_behaves_like 'a contagion instant summary count of population', :healthy
  end
end
