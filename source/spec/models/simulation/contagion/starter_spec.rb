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

  before { simulation.save }

  fdescribe '#process' do
    it do
      expect { starter.process }
        .to change { contagion.reload.instants.size }
        .by(1)
    end

    context "when the proccess is over" do
      let(:instant) { contagion.instants.last }

      before { starter.process }

      it do
        expect(instant.populations)
          .to have(4).elements
      end

      it "creates populations with the same size of groups" do
        expect(instant.populations.sum(:size))
          .to eq(300)
      end

      it "creates populations for infected" do
        expect(instant.populations.infected.sum(:size))
          .to eq(110)
      end

      it "creates populations for healthy" do
        expect(instant.populations.healthy.sum(:size))
          .to eq(190)
      end
    end
  end
end
