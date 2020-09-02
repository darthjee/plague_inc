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
