# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::PostCreator do
  subject(:post_creator) { described_class.new(instant) }

  let!(:simulation) { create(:simulation, contagion: contagion) }
  let(:contagion) do
    build(
      :contagion,
      simulation: nil,
      lethality: lethality,
      days_till_recovery: 11
    )
  end

  let!(:instant) do
    create(:contagion_instant, contagion: contagion)
  end

  let(:group) { contagion.reload.groups.last }

  let(:state) { :infected }

  before do
    [7, 10, 16].map do |day|
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
        expect { post_creator.process }
          .to change { instant.reload.populations.order(:id).pluck(:size) }
          .to([10, 0, 0])
      end

      it 'recovers those ready to be recovered' do
        expect { post_creator.process }
          .to change { instant.reload.populations.order(:id).map(&:state) }
          .to(%w[infected infected immune])
      end

      it 'resets counter of the recovered' do
        expect { post_creator.process }
          .to change { instant.reload.populations.order(:id).map(&:days) }
          .to([7, 10, 0])
      end

      it 'update instant status' do
        expect { post_creator.process }
          .to change { instant.reload.status }
          .from('created').to('ready')
      end
    end

    context 'when lethality is 100% but populations are not infected' do
      let(:lethality) { 1 }
      let(:state)     { :healthy }

      it 'kills no one' do
        expect { post_creator.process }
          .not_to(change { instant.populations.pluck(:size) })
      end

      it 'recovers no one' do
        expect { post_creator.process }
          .not_to(change { instant.reload.populations.map(&:state) })
      end
    end

    context 'when lethality is 0%' do
      let(:lethality) { 0 }

      it 'kills no one to be killed' do
        expect { post_creator.process }
          .not_to(change { instant.populations.pluck(:size) })
      end

      it 'recovers those ready to be recovered' do
        expect { post_creator.process }
          .to change { instant.reload.populations.order(:id).map(&:state) }
          .to(%w[infected infected immune])
      end
    end
  end
end
