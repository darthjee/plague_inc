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
        behavior: behavior,
        size: 1,
        state: :infected
      )
    end

    let(:selected_population) { populations.find(&:infected?) }
    let(:populations)         { current_instant.populations }

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

      context 'when there is only one interaction left' do
        let(:interactions) { 1 }

        it 'consumes infected interactions' do
          expect { process }
            .to change { infected_population.reload.interactions }
            .to(0)
        end
      end
    end

    context 'when there is a healthy population' do
      let!(:healthy_population) do
        create(
          :contagion_population,
          instant: current_instant,
          group: group,
          size: healthy_size,
          interactions: healthy_size * interactions,
          behavior: behavior,
          state: :healthy
        )
      end

      let(:healthy_size) { 10 }
      let(:new_infected_population) do
        new_instant
          .reload.populations
          .infected.find_by(days: 0)
      end

      let(:population_creation_check) do
        proc do
          new_instant
            .reload.populations.infected
            .where(days: 0).count
        end
      end

      it 'consumes infected interactions' do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end

      it 'infects some healthy people' do
        expect { process }
          .to change(&population_creation_check)
          .by(1)
      end

      it 'register new infections' do
        expect { process }
          .to(change { healthy_population.reload.new_infections })
      end

      it 'register new infections as they were infected' do
        process

        expect(healthy_population.reload.new_infections)
          .to eq(new_infected_population.size)
      end
    end

    context 'when there is a dead population' do
      let!(:healthy_population) do
        create(
          :contagion_population, :healthy,
          instant: current_instant,
          group: group,
          size: healthy_size,
          interactions: healthy_size * interactions,
          behavior: behavior,
        )
      end

      let!(:dead_population) do
        create(
          :contagion_population, :dead,
          instant: current_instant,
          group: group,
          size: healthy_size * 100,
          interactions: healthy_size * interactions * 100,
          behavior: behavior
        )
      end


      let(:healthy_size) { 100 }
      let(:interactions) { 1 }

      it 'consumes infected interactions' do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end

      it 'consumes healthy population interactions' do
        expect { process }
          .to change { healthy_population.reload.interactions }
          .by(-1)
      end

      it 'register new infections' do
        expect { process }
          .to change { healthy_population.reload.new_infections }.by(1)
      end
    end
  end
end