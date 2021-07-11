# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Contagion::Reparator do
  subject(:process) { described_class.process(simulation_id, day) }

  let(:simulation_id) { simulation.id }
  let(:simulation)   { contagion.simulation }
  let(:contagion)    { create(:contagion, size: size, status: :finished) }
  let(:size)         { Random.rand(100..1000) }
  let(:group)        { contagion.groups.first }

  describe '.process' do
    let(:day) { 0 }
    let!(:day_0) do
      create(:contagion_instant, day: 0, contagion: contagion)
    end

    before do
      create(
        :contagion_population, :infected,
        size: size / 4,
        instant: day_0,
        group: group
      )
    end

    context "when there is only one instant" do
      it do
        expect { process }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it "removes all instants" do
        expect { process }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it "removes populations" do
        expect { process }
          .to change(Simulation::Contagion::Population, :count)
          .by(-1)
      end
    end

    context "when there are 2 instants one instant" do
      let(:day) { 1 }
      let!(:day_1) do
        create(:contagion_instant, day: 1, contagion: contagion)
      end

      before do
        create(
          :contagion_population, :infected,
          size: size / 2,
          instant: day_1,
          group: group
        )
      end

      it do
        expect { process }.to change { simulation.reload.status }
          .to(Simulation::CREATED)
      end

      it "removes all instants" do
        expect { process }
          .to change { simulation.reload.contagion.instants.size }
          .to(0)
      end

      it "removes populations" do
        expect { process }
          .to change(Simulation::Contagion::Population, :count)
          .by(-2)
      end
    end
  end
end
