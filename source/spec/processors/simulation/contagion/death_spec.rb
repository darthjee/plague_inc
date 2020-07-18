# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Death do
  let(:population) do
    create(:contagion_population, group: group, behavior: behavior, size: size)
  end

  let(:size) { Random.rand(20..39) }

  let(:contagion)  { create(:contagion, lethality: lethality) }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { contagion.behaviors.first }

  describe '.process' do
    context 'when death rate is 100%' do
      let(:lethality) { 1 }

      it 'kill all people' do
        expect { described_class.process(population, contagion) }
          .to change(population, :size)
          .to(0)
      end

      it 'do not update population in database' do
        expect { described_class.process(population, contagion) }
          .not_to(change { population.reload.size })
      end

      it 'returns all that died' do
        expect(described_class.process(population, contagion))
          .to eq(size)
      end
    end

    context 'when death rate is 0%' do
      let(:lethality) { 0 }

      it 'kill all people' do
        expect { described_class.process(population, contagion) }
          .not_to change(population, :size)
      end

      it 'returns all that died' do
        expect(described_class.process(population, contagion))
          .to be_zero
      end
    end
  end
end
