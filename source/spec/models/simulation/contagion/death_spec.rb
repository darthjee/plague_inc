# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::Death do
  subject(:death) { described_class.new }

  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:group)      { contagion.groups.first }
  let(:behavior)   { create(:contagion_behavior, contagion: contagion) }

  let(:instant) { create(:contagion_instant, contagion: contagion) }
  let(:population) do
    create(
      :contagion_population,
      instant: instant,
      group: group,
      behavior: behavior
    )
  end

  describe 'kill' do
    it 'stores kill of a group' do
      expect { death.kill(population, 10) }
        .to change(death, :store)
        .from({})
        .to({ group => 10 })
    end

    context 'when size is 0' do
      it do
        expect { death.kill(population, 0) }
          .not_to change(death, :store)
      end
    end

    context 'when same group had been killed before' do
      let(:other_population) do
        create(
          :contagion_population,
          instant: instant,
          group: group,
          behavior: behavior,
          days: 10
        )
      end

      before do
        death.kill(other_population, 20)
      end

      fit 'stores kill of a group' do
        expect { death.kill(population, 10) }
          .to change(death, :store)
          .from({ group => 20 })
          .to({ group => 30 })
      end
    end
  end
end
