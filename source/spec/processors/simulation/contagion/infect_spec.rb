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
      interactions: behavior_interactions - 1
    )
  end

  let(:infected_behavior) do
    create(:contagion_behavior, contagion_risk: infected_risk)
  end

  let(:healthy_behavior) do
    create(
      :contagion_behavior,
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

  describe 'process' do
    let(:new_populations) do
      described_class.process(new_instant, infected, healthy, interactions)
    end

    context 'when entire population gets infected' do
      it 'builds populations for new instant' do
      end

      xit 'consumes infected interactions' do
        expect {  }
      end
    end
  end
end
