# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::PopulationInfector, :contagion_cache do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }

  let(:day) { Random.rand(10..29) }
  let(:days) { Random.rand(day + 1) }

  let(:instant) do
    create(:contagion_instant, contagion: contagion, day: day)
  end

  let(:new_instant) do
    create(:contagion_instant, contagion: contagion, day: day + 1)
  end

  let(:behavior) { contagion.behaviors.first }
  let(:group) do
    create(
      :contagion_group,
      contagion: contagion,
      behavior: behavior
    )
  end

  let(:infected) do
    create(
      :contagion_population,
      state: :infected,
      days: days,
      group: group,
      behavior: infected_behavior
    )
  end

  let(:healthy) do
    create(
      :contagion_population,
      state: :healthy,
      days: day,
      group: group,
      behavior: healthy_behavior,
      size: healthy_size,
      interactions: population_interactions,
      new_infections: new_infections
    )
  end

  let(:infected_behavior) do
    create(
      :contagion_behavior,
      name: 'infected',
      contagion_risk: infected_risk
    )
  end

  let(:healthy_behavior) do
    create(
      :contagion_behavior,
      name: 'healthy',
      contagion_risk: healthy_risk,
      interactions: behavior_interactions
    )
  end

  let(:healthy_size)          { 10 }
  let(:infected_risk)         { 1 }
  let(:healthy_risk)          { 1 }
  let(:behavior_interactions) { 2 }
  let(:new_infections)        { 0 }
  let(:interactions) do
    (behavior_interactions * (healthy_size - 1)) + 1
  end
  let(:population_interactions) do
    (healthy_size * behavior_interactions) - interactions
  end

  describe 'process' do
    let(:new_population) do
      described_class.process(
        new_instant, infected, healthy, interactions, cache: cache
      )
    end

    context 'when entire population gets infected' do
      it 'builds population for new instant' do
        expect(new_population)
          .to be_a(Simulation::Contagion::Population)
      end

      it do
        expect(new_population).not_to be_persisted
      end

      it 'initialize days' do
        expect(new_population.days)
          .to be_zero
      end

      it 'sets new population size' do
        expect(new_population.size)
          .to eq(healthy.size)
      end

      it 'sets group' do
        expect(new_population.group)
          .to eq(group)
      end

      it 'sets behavior' do
        expect(new_population.behavior)
          .to eq(healthy_behavior)
      end

      it 'consumes infected interactions' do
        expect { new_population }
          .to change(healthy, :interactions)
          .to(0)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .to change(healthy, :new_infections)
          .from(0).to(healthy_size)
      end

      it 'creates populations on new_instant' do
        expect { new_population }
          .to change { new_instant.populations.size }
          .by(1)
      end
    end

    context 'when healthy get protected' do
      let(:healthy_risk) { 0 }

      it do
        expect(new_population).to be_nil
      end

      it 'do not creates new population' do
        expect { new_population }
          .not_to(change { new_instant.populations.size })
      end

      it do
        expect { new_population }
          .not_to change(healthy, :interactions)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .not_to change(healthy, :new_infections)
      end
    end

    context 'when infected get protected' do
      let(:infected_risk) { 0 }

      it do
        expect(new_population).to be_nil
      end

      it 'do not creates new population' do
        expect { new_population }
          .not_to(change { new_instant.populations.size })
      end

      it do
        expect { new_population }
          .not_to change(healthy, :interactions)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .not_to change(healthy, :new_infections)
      end
    end

    context 'when a person is selected more than it should' do
      let(:healthy_size)            { 10 }
      let(:behavior_interactions)   { 1 }
      let(:population_interactions) { 0 }
      let(:interactions)            { 10 }

      it 'sets new population size' do
        expect(new_population.size)
          .to eq(healthy.size)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .to change(healthy, :new_infections)
          .from(0).to(healthy_size)
      end
    end

    context 'when person is infected but still has interactions' do
      let(:healthy_size)            { 2 }
      let(:behavior_interactions)   { 10 }
      let(:population_interactions) { 19 }
      let(:interactions)            { 1 }

      it 'sets new population size' do
        expect(new_population.size)
          .to eq(1)
      end

      it 'consumes infected interactions' do
        expect { new_population }
          .to change(healthy, :interactions)
          .to(10)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .to change(healthy, :new_infections)
          .from(0).to(1)
      end
    end

    context 'when population has alread been infected' do
      let(:healthy_size)            { 10 }
      let(:behavior_interactions)   { 10 }
      let(:population_interactions) { 4 }
      let(:interactions)            { 6 }
      let(:new_infections)          { healthy_size - 1 }

      let!(:existing_population) do
        create(
          :contagion_population,
          state: :infected,
          days: 0,
          group: group,
          behavior: healthy_behavior,
          size: new_infections,
          instant: new_instant
        )
      end

      before { new_instant.reload }

      it 'returns build instant' do
        expect(new_population)
          .to be_a(Simulation::Contagion::Population)
      end

      it 'retrieves existing population' do
        expect(new_population)
          .to eq(existing_population)
      end

      it 'does not create populations on new_instant' do
        expect { new_population }
          .not_to(change { new_instant.populations.size })
      end

      it 'updates new population size' do
        expect(new_population.size)
          .to eq(healthy_size)
      end

      it 'consumes infected interactions' do
        expect { new_population }
          .to change(healthy, :interactions)
          .to(0)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .to change(healthy, :new_infections)
          .from(new_infections).to(healthy_size)
      end
    end

    context 'when population has not many interactions left' do
      let(:healthy_size)            { 2 }
      let(:new_infections)          { 1 }
      let(:population_interactions) { 1 }
      let(:behavior_interactions)   { 3 }
      let(:interactions)            { 1 }
      let!(:existing_population) do
        create(
          :contagion_population,
          state: :infected,
          days: 0,
          group: group,
          behavior: healthy_behavior,
          size: new_infections,
          instant: new_instant
        )
      end

      it 'returns build instant' do
        expect(new_population)
          .to be_a(Simulation::Contagion::Population)
      end

      it 'retrieves existing population' do
        expect(new_population)
          .to eq(existing_population)
      end

      it 'does not create populations on new_instant' do
        expect { new_population }
          .not_to(change { new_instant.populations.size })
      end

      it 'updates new population size' do
        expect(new_population.size)
          .to eq(healthy_size)
      end

      it 'consumes infected interactions' do
        expect { new_population }
          .to change(healthy, :interactions)
          .to(0)
      end

      it 'marks the number of infecteds' do
        expect { new_population }
          .to change(healthy, :new_infections)
          .from(new_infections).to(healthy_size)
      end
    end
  end
end
