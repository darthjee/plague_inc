# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Healer do
  let!(:simulation) { create(:simulation, contagion: contagion) }
  let(:contagion) do
    build(
      :contagion,
      simulation: nil,
      days_till_recovery: 11
    )
  end

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  let(:group)  { contagion.reload.groups.last }
  let(:states) { Simulation::Contagion::Population::STATES }

  before do
    states.map do |state|
      create(
        :contagion_population,
        group: group,
        behavior: group.behavior,
        instant: instant,
        days: 16,
        size: 10,
        state: state
      )
    end

    simulation.contagion.reload
  end

  describe '.process' do
    it 'recovers those ready to be recovered' do
      expect { described_class.process(instant) }
        .to change { instant.populations.map(&:state).sort }
        .to(%w[healthy immune immune])
    end

    it 'resets day counter' do
      expect { described_class.process(instant) }
        .to change { instant.populations.map(&:days).sort }
        .to([0, 16, 16])
    end

    it 'does not persist change' do
      expect { described_class.process(instant) }
        .not_to(change { instant.reload.populations.map(&:state) })
    end

    context 'when populations are not infected' do
      let(:states) do
        [
          Simulation::Contagion::Population::IMMUNE,
          Simulation::Contagion::Population::HEALTHY
        ]
      end

      it 'does not recover anyone' do
        expect { described_class.process(instant) }
          .not_to(change { instant.populations.map(&:state).sort })
      end

      it 'does not reset day counter' do
        expect { described_class.process(instant) }
          .not_to(change { instant.populations.map(&:days) })
      end
    end
  end
end
