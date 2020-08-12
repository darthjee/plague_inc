# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Starter do
  let(:simulation) { build(:simulation, :processing, settings: contagion) }
  let(:contagion)  { build(:contagion, groups: [], behaviors: []) }

  let!(:groups) do
    [0, 10, 100].map.with_index do |infected, index|
      contagion.groups.build(
        name: "G#{index}",
        reference: "g#{index}",
        size: 100,
        behavior: behaviors[index],
        infected: infected
      )
    end
  end

  let!(:behaviors) do
    3.times.map do |index|
      contagion.behaviors.build(
        name: "B#{index}",
        reference: "b#{index}",
        contagion_risk: 0.5,
        interactions: 10,
        contagion: contagion
      )
    end
  end

  before { simulation.save }

  describe '.process' do
    it 'updates simulation' do
      expect { described_class.process(contagion) }
        .to change { simulation.reload.updated_at }
    end

    it 'does not update simulation status' do
      expect { described_class.process(contagion) }
        .not_to(change { simulation.reload.status })
    end

    it do
      expect { described_class.process(contagion) }
        .to change { contagion.reload.instants.size }
        .by(1)
    end

    it do
      expect(described_class.process(contagion))
        .to be_a(Simulation::Contagion::Instant)
    end

    it do
      expect(described_class.process(contagion))
        .to be_persisted
    end

    context 'when the proccess is over' do
      let(:instant) { contagion.instants.last }

      before { described_class.process(contagion) }

      it do
        expect(instant.populations)
          .to have(4).elements
      end

      it 'creates populations for all groups' do
        expect(instant.populations.map(&:group).uniq)
          .to eq(groups)
      end

      it 'creates populations with the same size of groups' do
        expect(instant.populations.sum(:size))
          .to eq(300)
      end

      it 'creates populations for infected' do
        expect(instant.populations.infected.sum(:size))
          .to eq(110)
      end

      it 'creates populations for infected with 0 days' do
        expect(instant.populations.pluck(:days).uniq)
          .to eq([0])
      end

      it 'creates populations for healthy' do
        expect(instant.populations.healthy.sum(:size))
          .to eq(190)
      end

      it 'creates populations with right behavior' do
        instant.populations.each do |population|
          expect(population.behavior)
            .to eq(population.group.behavior)
        end
      end
    end
  end
end
