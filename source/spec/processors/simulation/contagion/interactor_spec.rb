# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Interactor do
  describe '.process' do
    let(:simulation) do
      build(:simulation, contagion: nil).tap do |sim|
        sim.save(validate: false)
      end
    end

    let(:contagion) do
      build(
        :contagion,
        simulation: simulation,
        lethality: lethality,
        groups: [],
        behaviors: []
      ).tap do |con|
        con.save(validate: false)
      end
    end

    let!(:group) do
      create(
        :contagion_group,
        infected: infected,
        behavior: behavior,
        contagion: contagion
      )
    end

    let!(:behavior) do
      create(
        :contagion_behavior,
        contagion: contagion,
        interactions: interactions
      )
    end

    let!(:current_instant) do
      create(
        :contagion_instant,
        contagion: contagion,
        day: day
      )
    end

    let!(:new_instant) do
      Simulation::Contagion::Initializer.process(
        current_instant
      )
    end

    let!(:infected_population) do
      create(
        :contagion_population,
        interactions: interactions,
        instant: current_instant,
        group: group,
        size: 1
      )
    end

    let(:random_box)   { RandomBox.instance }
    let(:day)          { 0 }
    let(:infected)     { 1 }
    let(:interactions) { 10 }
    let(:lethality)    { 1 }

    it do
      expect { described_class.process(current_instant, new_instant) }
        .to change { current_instant.reload.status }
        .from(Simulation::Contagion::Instant::PROCESSING)
        .to(Simulation::Contagion::Instant::PROCESSED)
    end
  end
end
