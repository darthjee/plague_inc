# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::PostCreator do
  let!(:simulation) do
    create(:simulation, :processing, contagion: contagion)
  end

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
  let(:size)  { Random.rand(10..20) }
  let(:expected_interactions) do
    size * 15
  end

  before do
    [7, 10, 16].map do |day|
      create(
        :contagion_population, state,
        group: group,
        behavior: group.behavior,
        instant: instant,
        days: day,
        size: size,
        interactions: 0
      )
    end

    simulation.contagion.reload
  end

  describe '.process' do
    context 'when lethality is 100%' do
      let(:lethality) { 1 }

      it 'updates simulation' do
        expect { described_class.process(instant) }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { described_class.process(instant) }
          .not_to(change { simulation.reload.status })
      end

      it 'kills everyone ready to be killed' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.order(:id).pluck(:size) }
          .to([size, 0, 0, 2 * size])
      end

      it 'recovers those ready to be recovered' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.order(:id).map(&:state) }
          .to(%w[infected infected immune dead])
      end

      it 'resets counter of the recovered' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.order(:id).map(&:days) }
          .to([7, 10, 0, 0])
      end

      it 'update instant status' do
        expect { described_class.process(instant) }
          .to change { instant.reload.status }
          .from('created').to('ready')
      end

      it 'sets population interactions' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.order(:id).map(&:interactions) }
          .to([expected_interactions, 0, 0, 2 * expected_interactions])
      end
    end

    context 'when lethality is 100% but populations are not infected' do
      let(:lethality) { 1 }
      let(:state)     { :healthy }

      it 'updates simulation' do
        expect { described_class.process(instant) }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { described_class.process(instant) }
          .not_to(change { simulation.reload.status })
      end

      it 'kills no one' do
        expect { described_class.process(instant) }
          .not_to(change { instant.populations.pluck(:size) })
      end

      it 'recovers no one' do
        expect { described_class.process(instant) }
          .not_to(change { instant.reload.populations.map(&:state) })
      end

      it 'sets population interactions' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.map(&:interactions) }
          .to(3.times.map { expected_interactions })
      end
    end

    context 'when lethality is 0%' do
      let(:lethality) { 0 }

      it 'updates simulation' do
        expect { described_class.process(instant) }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { described_class.process(instant) }
          .not_to(change { simulation.reload.status })
      end

      it 'kills no one to be killed' do
        expect { described_class.process(instant) }
          .not_to(change { instant.populations.pluck(:size) })
      end

      it 'recovers those ready to be recovered' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.order(:id).map(&:state) }
          .to(%w[infected infected immune])
      end

      it 'sets population interactions' do
        expect { described_class.process(instant) }
          .to change { instant.reload.populations.map(&:interactions) }
          .to(3.times.map { expected_interactions })
      end
    end
  end
end
