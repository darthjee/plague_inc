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
      interactions: healthy_size * interactions
    )
  end

  let(:infected_behavior) do
    create(:contagion_behavior, contagion_risk: infected_risk)
  end

  let(:healthy_behavior) do
    create(
      :contagion_behavior,
      contagion_risk: healthy_risk,
      interactions: interactions
    )
  end

  let(:healthy_size)  { 10 }
  let(:infected_risk) { 1 }
  let(:healthy_risk)  { 1 }
  let(:interactions)  { 2 }

  let(:random_box) { double(RandomBox) }

  before do
    allow(RandomBox).to receive(:new).and_return(random_box)
  end

  describe 'process' do
    before do
      allow(random_box)
        .to receive(:individual)
        .and_return(0)
    end
  end
end
