# frozen_string_literal: true

require 'spec_helper'

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
    context 'when there is no population' do
      it { expect(decorator.dead).to be_zero }
    end

    context 'when there are only alive populations' do
      let(:populations) { Random.rand(2..10) }
      let(:states) do
        [
          Simulation::Contagion::Population::INFECTED,
          Simulation::Contagion::Population::HEALTHY,
          Simulation::Contagion::Population::IMMUNE
        ]
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

      it { expect(decorator.dead).to be_zero }
    end

    context 'when there are dead and alive populations' do
      let(:alive_populations) { Random.rand(2..10) }
      let(:dead_populations) { Random.rand(2..10) }
      let(:dead_sizes) do
        dead_populations.times.map { Random.rand(100..500) }
      end
      let(:alive_states) do
        [
          Simulation::Contagion::Population::INFECTED,
          Simulation::Contagion::Population::HEALTHY,
          Simulation::Contagion::Population::IMMUNE
        ]
      end

      before do
        alive_populations.times.each do |days|
          create(
            :contagion_population,
            state: alive_states.sample,
            instant: instant,
            group: group,
            behavior: behavior,
            days: days
          )
        end

        dead_sizes.each.with_index do |size, days|
          create(
            :contagion_population, :dead,
            instant: instant,
            group: group,
            behavior: behavior,
            days: days,
            size: size
          )
        end
      end


      it 'returns the sum of dead sizes' do
        expect(decorator.dead).to eq(dead_sizes.sum)
      end
    end
  end
end
