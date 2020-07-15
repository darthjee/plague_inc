# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Killer do
  subject(:killer) { described_class.new(instant, contagion) }

  let!(:simulation) { create(:simulation, contagion: contagion) }
  let(:contagion) do
    build(:contagion, simulation: nil, lethality: lethality)
  end

  let(:group) { contagion.reload.groups.last }

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  let(:state) { :infected }

  before do
    [9, 10, 11].map do |day|
      create(
        :contagion_population,
        group: group,
        behavior: group.behavior,
        instant: instant,
        days: day,
        size: 10,
        state: state
      )
    end

    simulation.contagion.reload
  end

  describe '#process' do
    context 'when lethality is 100%' do
      let(:lethality) { 1 }

      it 'kills everyone ready to be killed' do
        expect { killer.process }
          .to change { instant.populations.pluck(:size) }
          .to([10, 0, 0])
      end

      it 'does not persist killing' do
        expect { killer.process }
          .not_to(change { instant.reload.populations.pluck(:size) })
      end
    end

    context 'when lethality is 100% but populations are not infected' do
      let(:lethality) { 1 }
      let(:state)     { :healthy }

      it 'kills no one' do
        expect { killer.process }
          .not_to(change { instant.populations.pluck(:size) })
      end
    end

    context 'when lethality is 0%' do
      let(:lethality) { 0 }

      it 'kills no one to be killed' do
        expect { killer.process }
          .not_to(change { instant.populations.pluck(:size) })
      end
    end
  end
end
