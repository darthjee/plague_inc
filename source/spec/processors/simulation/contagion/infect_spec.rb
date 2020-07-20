# frozen_string_literal: true

require 'spec_helper'

describe Simulation::Contagion::Infect do
  let(:simulation) { create(:simulation) }
  let(:contagion)  { simulation.contagion }

  let(:day) { Random.rand(20) + 10 }
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
      interactions: population_interactions
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
  let(:interactions) do
    behavior_interactions * (healthy_size - 1) + 1
  end
  let(:population_interactions) do
    healthy_size * behavior_interactions - interactions
  end

  describe 'process' do
    let(:new_population) do
      described_class.process(new_instant, infected, healthy, interactions)
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
          .to change { healthy.interactions }
          .to(0)
      end

      it 'creates populations on new_instant' do
        expect { new_population }
          .to change { new_instant.populations.size }
          .by(1)
      end
    end
  end
end
