# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::Healer do
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

  let(:state) { :infected }

  before do
    Simulation::Contagion::Population::STATES.map do |sate|
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
    context 'when lethality is 100%' do
      it 'recovers those ready to be recovered' do
        expect { post_creator.process }
          .to change { instant.populations.map(&:state) }
          .to(%w[infected infected immune])
      end
    end
  end
end

