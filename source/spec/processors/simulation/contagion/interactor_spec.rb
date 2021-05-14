# frozen_string_literal: true

require 'spec_helper'

shared_context 'with infected random box', mock_random: true do
  before do
    allow(random_box).to receive(:interaction) do
      index = 0
      current_instant.populations.find do |population|
        if population.healthy? && population.interactions.positive?
          true
        else
          index += population.interactions
          false
        end
      end
      index
    end
  end
end

describe Simulation::Contagion::Interactor, :contagion_cache do
  describe '.process' do
    let(:simulation) do
      build(:simulation, :processing, contagion: nil).tap do |sim|
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

    let(:second_group) do
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
        current_instant, cache: cache
      )
    end

    let(:options) do
      Simulation::Processor::Options.new
    end

    let(:random_box)     { RandomBox.instance }
    let(:day)            { 0 }
    let(:infected)       { 1 }
    let(:lethality)      { 1 }
    let(:infected_size)  { Random.rand(10..30) }
    let(:interactions)   { Random.rand(10..30) }
    let(:contagion_risk) { Random.rand(0.3..0.7) }

    let(:infected_interactions) { infected_size * interactions }
    let(:healthy_size)          { 100 * infected_size }
    let(:healthy_interactions)  { healthy_size * interactions }

    let(:infected_population_query) do
      current_instant.populations.infected
    end

    let(:process) do
      described_class.process(
        current_instant, new_instant, options, cache: cache
      )
    end

    let!(:infected_population) do
      create(
        :contagion_population, :infected,
        interactions: infected_interactions,
        instant: current_instant,
        group: group,
        size: infected_size,
        behavior: behavior
      )
    end

    before do
      simulation.reload.update(updated_at: 1.days.ago)
    end

    it 'updates simulation' do
      expect { process }
        .to(change { simulation.reload.updated_at })
    end

    it 'does not update simulation status' do
      expect { process }
        .not_to(change { simulation.reload.status })
    end

    it do
      expect { process }
        .to change { current_instant.reload.status }
        .from(Simulation::Contagion::Instant::PROCESSING)
        .to(Simulation::Contagion::Instant::PROCESSED)
    end

    it do
      expect { process }
        .not_to(change { new_instant.reload.status })
    end

    it "consumes interactions of infected population" do
      expect { process }
        .to change { infected_population.reload.interactions }
        .to(0)
    end

    context 'when there is only an infected population' do
      it do
        expect { process }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create a new population' do
        expect { process }
          .not_to(change { new_instant.populations.reload.count })
      end

      it 'does not increase infected populations size' do
        expect { process }
          .not_to(change { new_instant.populations.reload.sum(:size) })
      end
    end

    context 'when there is a healthy population' do
      let!(:healthy_population) do
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior
        )
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it do
        expect { process }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'creates a new population' do
        expect { process }
          .to change { new_instant.populations.reload.count }
          .by(1)
      end

      it 'increase infected populations size' do
        expect { process }
          .to(change { new_instant.reload.populations.sum(:size) })
      end

      it 'consumes interactions from healthy population' do
        expect { process }
          .to(change { healthy_population.reload.interactions })
      end

      it "consumes interactions of infected population" do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end
    end

    context 'when there is a another infected population' do
      before do
        create(
          :contagion_population, :infected,
          interactions: infected_interactions,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it do
        expect { process }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create a new population' do
        expect { process }
          .not_to(change { new_instant.populations.reload.count })
      end

      it 'does not increase infected populations size' do
        expect { process }
          .not_to(change { new_instant.populations.reload.sum(:size) })
      end

      it "consumes interactions of infected population" do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end
    end

    context 'when there are other populations', :mock_random do
      let(:healthy_size)   { infected_size }
      let(:contagion_risk) { 1 }

      before do
        create(
          :contagion_population, :infected,
          interactions: infected_interactions,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions,
          instant: current_instant,
          group: second_group,
          size: healthy_size,
          behavior: behavior
        )

        current_instant.reload
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it do
        expect { process }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'creates a new population for the healthy population' do
        expect { process }
          .to change { new_instant.populations.reload.count }
          .by(2)
      end

      it 'increases infected populations size' do
        expect { process }
          .to change { new_instant.populations.reload.sum(:size) }
          .by(2 * healthy_size)
      end

      it "consumes interactions of infected population" do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end
    end

    context 'when one population has been processed already', :mock_random do
      let(:healthy_size)   { infected_size }
      let(:infected_size)  { 2 * Random.rand(3..10) }
      let(:contagion_risk) { 1 }

      before do
        create(
          :contagion_population, :infected,
          interactions: 0,
          instant: current_instant,
          group: second_group,
          size: infected_size,
          behavior: behavior
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions / 2,
          instant: current_instant,
          group: group,
          size: healthy_size,
          behavior: behavior,
          new_infections: healthy_size / 2
        )
        create(
          :contagion_population, :healthy,
          interactions: healthy_interactions / 2,
          instant: current_instant,
          group: second_group,
          size: healthy_size,
          behavior: behavior,
          new_infections: healthy_size / 2
        )

        create(
          :contagion_population, :infected,
          interactions: healthy_interactions / 2,
          instant: new_instant,
          group: group,
          size: healthy_size / 2,
          behavior: behavior
        )
        create(
          :contagion_population, :infected,
          interactions: healthy_interactions / 2,
          instant: new_instant,
          group: second_group,
          size: healthy_size / 2,
          behavior: behavior
        )
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it 'consumes interactions' do
        expect { process }
          .to change { infected_population_query.reload.sum(:interactions) }
          .to(0)
      end

      it 'does not create new populations' do
        expect { process }
          .not_to(change { new_instant.populations.reload.count })
      end

      it 'increases infected populations size' do
        expect { process }
          .to change { new_instant.populations.reload.sum(:size) }
          .by(healthy_size)
      end

      it 'ignores new infected populations interactions' do
        expect { process }
          .not_to(change { new_instant.populations.reload.sum(:interactions) })
      end

      it "consumes interactions of infected population" do
        expect { process }
          .to change { infected_population.reload.interactions }
          .to(0)
      end
    end

    context "when there are more interactions then block size" do
      let!(:healthy_population) do
        create(
          :contagion_population, :healthy,
          interactions: infected_interactions,
          instant: current_instant,
          group: group,
          size: infected_size,
          behavior: behavior
        )
      end

      before do
        allow(options)
          .to receive(:interaction_block_size)
          .and_return(1)
      end

      it 'updates simulation' do
        expect { process }
          .to(change { simulation.reload.updated_at })
      end

      it 'does not update simulation status' do
        expect { process }
          .not_to(change { simulation.reload.status })
      end

      it do
        expect { process }
          .not_to change { current_instant.reload.status }
      end

      it do
        expect { process }
          .not_to(change { new_instant.reload.status })
      end

      it "consumes some interactions" do
        expect { process }
          .to change { infected_population.reload.interactions }
      end

      it "consumes interactions from both interactors" do
        expect { process }
          .to change { current_instant.reload.populations.sum(:interactions) }
          .by(-2)
      end
    end
  end
end
