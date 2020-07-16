# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Healer do
  subject(:post_creator) { described_class.new(instant) }

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

  let(:group) { contagion.reload.groups.last }

  before do
    Simulation::Contagion::Population::STATES.map do |state|
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

  describe '#process' do
    it 'recovers those ready to be recovered' do
      expect { post_creator.process }
        .to change { instant.populations.map(&:state) }
        .to(%w[immune healthy immune])
    end

    it 'resets day counter' do
      expect { post_creator.process }
        .to change { instant.populations.map(&:days) }
        .to([0, 16, 16])
    end


    it 'does not persist change' do
      expect { post_creator.process }
        .not_to change { instant.reload.populations.map(&:state) }
    end
  end
end
