# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::InteractionStore do
  subject(:store) { described_class.new(contagion_risk, population) }

  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }
  let(:instant)    { create(:contagion_instant) }

  let(:population) do
    create(
      :contagion_population,
      behavior: behavior,
      group: group
    )
  end

  let(:group) do
    create(
      :contagion_group,
      contagion: contagion,
      behavior: behavior
    )
  end

  let(:behavior) do
    create(
      :contagion_behavior,
      contagion: contagion,
      interactions: interactions
    )
  end

  let(:contagion_risk) { 1 }
  let(:interactions)   { Random.rand(2..10) }

  describe '#interact' do
    context 'when contagion risk is 100%' do
      it do
        expect { store.interact }
          .to change(store, :infected)
          .by(1)
      end

      it do
        expect { store.interact }
          .to change(store, :ignored_interactions)
          .by(interactions - 1)
      end

      context 'when called several times' do
        let(:times)        { 6 }
        let(:indexes)      { [0, 1, 0, 1, 0, 2] }
        let(:interactions) { 10 }

        # rubocop:disable RSpec/VerifiedDoubles
        let(:random_box) { double('RandomBox') }
        # rubocop:enable RSpec/VerifiedDoubles

        let(:responses) do
          [true, true, true, true, true, false]
        end

        before do
          allow(RandomBox).to receive(:new).and_return(random_box)
          allow(random_box).to receive(:<) { responses.shift }
          allow(random_box).to receive(:person) { indexes.shift }
        end

        it 'changes ignored_actions' do
          expect { times.times { store.interact } }
            .to change(store, :ignored_interactions)
            .by(15)
        end
      end
    end
  end
end
