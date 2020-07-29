# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::InfectedInteractor do
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
       interactions: interactions,
       contagion_risk: contagion_risk
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
        size: 1,
        interactions: interactions,
        state: :infected
      )
    end

    let(:selected_population) { populations.find(&:infected?) }
    let(:populations)         { current_instant.populations }

    let(:random_box)     { RandomBox.instance }
    let(:day)            { 0 }
    let(:infected)       { 1 }
    let(:interactions)   { 10 }
    let(:lethality)      { 1 }
    let(:contagion_risk) { 1 }

    let(:process) do
      described_class.process(
        selected_population,
        current_instant,
        new_instant
      )
    end

    context 'when person interacts with itself' do
      it 'consumes infected interactions' do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end
    end

    context 'when there is a healthy population' do
      let!(:healthy_population) do
        create(
          :contagion_population,
          interactions: interactions,
          instant: current_instant,
          group: group,
          size: healthy_size,
          interactions: healthy_size * interactions,
          state: :healthy
        )
      end

      let(:healthy_size) { 10 }

      it 'consumes infected interactions' do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end

      it 'infects some healthy people' do
        expect { process }
          .to change { 
          new_instant.reload.populations.infected
            .where(days: 0).count
        }.by(1)
      end
    end
  end
end
