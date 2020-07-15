# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Death do
  subject(:death) { described_class.new(population, contagion) }

  let(:population) do
    create(:contagion_population, group: group, behavior: behavior)
  end

  let(:contagion)  { create(:contagion, lethality: lethality) }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { contagion.behaviors.first }

  describe '#process' do
    context 'when death rate is 100%' do
      let(:lethality) { 1 }

      it 'kill all people' do
        expect { death.process }
          .to change(population, :size)
          .to(0)
      end

      it 'do not update population in database' do
        expect { death.process }
          .not_to(change { population.reload.size })
      end
    end

    context 'when death rate is 0%' do
      let(:lethality) { 0 }

      it 'kill all people' do
        expect { death.process }
          .not_to change(population, :size)
      end
    end
  end
end
