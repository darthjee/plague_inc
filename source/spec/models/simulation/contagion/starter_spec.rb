# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Starter do
  subject(:starter) { described_class.new(simulation) }

  let(:simulation) { build(:simulation, settings: contagion) }

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

  let(:instants) { contagion.instants }

  before { simulation.save }

  fdescribe '#process' do
    it do
      expect { starter.process }
        .to change { contagion.reload.instants.size }
        .by(1)
    end

    it do
      expect { starter.process }
        .to change { instants.reload.last&.populations&.count.to_i }
        .by(4)
    end
  end
end
