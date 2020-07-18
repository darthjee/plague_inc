# frozen_string_literal: true

FactoryBot.define do
  factory :contagion_population, class: 'Simulation::Contagion::Population' do
    instant  { build(:contagion_instant) }
    group    { build(:contagion_group) }
    behavior { build(:contagion_behavior) }
    state    { :healthy }
    size     { 100 }

    interactions do
      behavior&.interactions.to_i * size
    end
  end
end
