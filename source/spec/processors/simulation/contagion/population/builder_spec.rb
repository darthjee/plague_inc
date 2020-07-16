# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Population::Builder do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:behavior)   { contagion.behaviors.last }
  let(:group) do
    create(
      :contagion_group,
      contagion: contagion,
      behavior: behavior,
      size: size,
      infected: infected
    )
  end

  let(:size)     { 300 }
  let(:infected) { 100 }

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  describe '.build' do
    subject(:population) do
      described_class.build(
        instant: instant,
        group: group,
        type: type
      )
    end

    context 'when type is healthy' do
      let(:type) do
        Simulation::Contagion::Population::HEALTHY
      end

      it do
        expect(population).not_to be_persisted
      end

      it do
        expect(population)
          .to be_a(Simulation::Contagion::Population)
      end

      it do
        expect(population.instant)
          .to eq(instant)
      end

      it do
        expect(population.behavior)
          .to eq(behavior)
      end

      it do
        expect(population.size)
          .to eq(size - infected)
      end

      it do
        expect(population).to be_healthy
      end
    end

    context 'when type is infected' do
      let(:type) do
        Simulation::Contagion::Population::INFECTED
      end

      it do
        expect(population).not_to be_persisted
      end

      it do
        expect(population)
          .to be_a(Simulation::Contagion::Population)
      end

      it do
        expect(population.instant)
          .to eq(instant)
      end

      it do
        expect(population.behavior)
          .to eq(behavior)
      end

      it do
        expect(population.size)
          .to eq(infected)
      end

      it do
        expect(population).to be_infected
      end
    end
  end
end
